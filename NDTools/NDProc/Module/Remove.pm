package NDTools::NDProc::Module::Remove;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Module";

use NDTools::INC;
use Log::Log4Cli;
use Struct::Path qw(spath);
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);

sub MODINFO { "Remove specified parts from structure" }
sub VERSION { "0.07" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'preserve=s@' => \$self->{OPTS}->{preserve},
        'strict' => \$self->{OPTS}->{strict},
    )
}

sub process {
    my ($self, $data, $opts) = @_;

    $self->stash_preserved($data, $opts->{preserve}) if ($opts->{preserve});

    map { $self->process_path($data, $_, $opts) } @{$opts->{path}};

    $self->restore_preserved($data) if ($opts->{preserve});
}

sub process_path {
    my ($self, $data, $path, $opts) = @_;

    my $spath = eval { ps_parse($path) };
    die_fatal "Failed to parse path ($@)", 4 if ($@);

    # until entire structure removal fixed in Struct::Path
    return ${$data} = undef unless (@{$spath});

    my @list = eval { spath($data, $spath, paths => 1, strict => $opts->{strict}) };
    die_fatal "Failed to resolve path '$path'", 4 if ($@);

    while (@list) {
        my ($p, undef) = splice @list, -2, 2;

        log_info { "Removing path '" . ps_serialize($p). "'" };
        spath($data, $p, delete => 1, strict => 1);
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

=item B<--path> E<lt>pathE<gt>

Path in the structure to remove. May be used several times.

=item B<--preserve> E<lt>pathE<gt>

Preserve specified structure parts. May be used several times.

=item B<--strict>

Fail if path specified for remove doesn't exists.

=back

=head1 SEE ALSO

L<ndproc(1)>, L<ndproc-modules>

L<nddiff(1)>, L<ndquery(1)>, L<Struct::Path::PerlStyle>
