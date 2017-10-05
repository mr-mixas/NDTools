package App::NDTools::NDProc::Module::Remove;

use strict;
use warnings FATAL => 'all';
use parent 'App::NDTools::NDProc::Module';

use Log::Log4Cli;
use Struct::Path qw(spath);
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);

sub MODINFO { "Remove specified parts from structure" }
sub VERSION { "0.07" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'strict' => \$self->{OPTS}->{strict},
    )
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

1; # End of App::NDTools::NDProc::Module::Remove

__END__

=head1 NAME

Remove - remove specified parts from structure

=head1 OPTIONS

=over 4

=item B<--[no]blame>

Blame calculation toggle. Enabled by default.

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
