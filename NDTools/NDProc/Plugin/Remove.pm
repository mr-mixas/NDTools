package NDTools::NDProc::Plugin::Remove;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Plugin";

use NDTools::INC;
use Log::Log4Cli;
use Struct::Path qw(spath);
use Struct::Path::PerlStyle qw(ps_parse);

sub MODINFO { "Remove specified parts from structure" }
sub VERSION { "0.01" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'strict' => \$self->{OPTS}->{strict},
    )
}

sub process {
    my ($self, $data, $opts) = @_;
    for my $path (@{$opts->{path}}) {
        log_debug { 'Removing path "' . $path . '"' };
        $path = eval { ps_parse($path) };
        die_fatal "Failed to parse path ($@)", 4 if ($@);
        eval { spath($data, $path, delete => 1, strict => $opts->{strict}) };
        die_fatal "Failed to remove path ($@)", 4 if ($@);
    }
}

1; # End of NDTools::NDProc::Plugin::Remove

__END__

=head1 NAME

Remove - remove specified parts from structure

=head1 OPTIONS

=over 4

=item B<--path> E<lt>pathE<gt>

Path in the structure to remove. May be used several times.

=item B<--strict>

Fail if path specified for remove doesn't exists.

=back

=head1 SEE ALSO

L<ndproc(1)>, L<ndproc-modules>

L<nddiff(1)>, L<ndquery(1)>, L<Struct::Path::PerlStyle>
