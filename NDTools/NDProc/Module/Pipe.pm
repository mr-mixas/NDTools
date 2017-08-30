package NDTools::NDProc::Module::Pipe;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Module";

use IPC::Run3;
use Log::Log4Cli;
use NDTools::Slurp qw(s_decode s_encode);
use Struct::Path qw(spath);
use Struct::Path::PerlStyle qw(ps_parse);

sub MODINFO { "Modify structure using external process" }
sub VERSION { "0.01" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'command|cmd=s' => \$self->{OPTS}->{command},
        'preserve=s@' => \$self->{OPTS}->{preserve},
        'strict' => \$self->{OPTS}->{strict},
    )
}

sub process {
    my ($self, $data, $opts) = @_;

    $self->stash_preserved($data, $opts->{preserve}) if ($opts->{preserve});

    # process full source if no paths defined # FIXME: move it to parent and make common for all mods
    push @{$opts->{path}}, '' unless (@{$opts->{path}});

    for my $path (@{$opts->{path}}) {
        my $spath = eval { ps_parse($path) };
        die_fatal "Failed to parse path ($@)", 4 if ($@);
        my @refs = eval { spath($data, $spath, strict => $opts->{strict}) };
        die_fatal "Failed to lookup path ($path)", 4 if ($@);

        for my $r (@refs) {
            my $in = s_encode(${$r}, 'JSON', { pretty => 1 });

            my ($out, $err);
            run3($opts->{command}, \$in, \$out, \$err, { return_if_system_error => 1});
            die_fatal "Failed to run '$opts->{command}' ($!)", 2 if ($? == -1); # run3 specific
            unless ($? == 0) {
                die_fatal "'$opts->{command}' exited with $? (" .
                    join(" ", split("\n", $err)) . ")", 16;
            }

            ${$r} = s_decode($out, 'JSON');
        }
    }

    $self->restore_preserved($data) if ($opts->{preserve});
}

1; # End of NDTools::NDProc::Module::Pipe

__END__

=head1 NAME

Pipe - pipe structure to external program and apply result.

=head1 OPTIONS

=over 4

=item B<--[no]blame>

Blame calculation toggle. Enabled by default.

=item B<--path> E<lt>pathE<gt>

Path in the structure to remove. May be used several times.

=item B<--preserve> E<lt>pathE<gt>

Preserve specified structure parts. May be used several times.

=item B<--strict>

Fail if specified path doesn't exists.

=back

=head1 SEE ALSO

L<ndproc(1)>, L<ndproc-modules>

L<nddiff(1)>, L<ndquery(1)>, L<Struct::Path::PerlStyle>
