package NDTools::NDProc::Module::Remove;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Module";

use NDTools::INC;
use Log::Log4Cli;
use Struct::Path qw(spath);
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);

sub MODINFO { "Remove specified parts from structure" }
sub VERSION { "0.05" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'ignore=s@' => \$self->{OPTS}->{ignore},
        'strict' => \$self->{OPTS}->{strict},
    )
}

sub process {
    my ($self, $data, $opts) = @_;

    my @stash;
    for my $path (@{$opts->{ignore}}) {
        log_debug { "Preserving '$path'" };
        my $spath = eval { ps_parse($path) };
        die_fatal "Failed to parse path ($@)", 4 if ($@);
        push @stash, spath($data, $spath, deref => 1, paths => 1);
    }

    for my $path (@{$opts->{path}}) {
        log_info { "Removing path '$path'" };
        my $spath = eval { ps_parse($path) };
        die_fatal "Failed to parse path ($@)", 4 if ($@);
        unless (@{$spath}) {
            ${$data} = undef;
            next;
        }
        eval { spath($data, $spath, delete => 1, strict => $opts->{strict}) };
        die_fatal "Failed to remove path ($@)", 4 if ($@);
    }

    for my $s (@stash) {
        log_debug { "Restoring '" . ps_serialize($s->[0]) . "'" };
        ${(spath($data, $s->[0], expand => 1))[0]} = $s->[1];
    }
}

1; # End of NDTools::NDProc::Module::Remove

__END__

=head1 NAME

Remove - remove specified parts from structure

=head1 OPTIONS

=over 4

=item B<--[no]blame>

Blame calculaton toggle. Enabled by default.

=item B<--ignore> E<lt>pathE<gt>

Preserve specified substructure. May be used several times.

=item B<--path> E<lt>pathE<gt>

Path in the structure to remove. May be used several times.

=item B<--strict>

Fail if path specified for remove doesn't exists.

=back

=head1 SEE ALSO

L<ndproc(1)>, L<ndproc-modules>

L<nddiff(1)>, L<ndquery(1)>, L<Struct::Path::PerlStyle>
