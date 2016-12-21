package NDTools::NDProc::Module::Insert;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Module";

use NDTools::INC;
use Log::Log4Cli;
use Struct::Path qw(spath);
use Struct::Path::PerlStyle qw(ps_parse);

sub MODINFO { "Insert structure/value into another structure" }
sub VERSION { "0.02" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'file|f=s' => \$self->{OPTS}->{file},
        'value=s' => \$self->{OPTS}->{value},
    )
}

sub configure {
    my $self = shift;
    $self->{OPTS}->{value} = $self->load_uri($self->{OPTS}->{file})
        if (defined $self->{OPTS}->{file});
}

sub process {
    my ($self, $data, $opts) = @_;
    for my $path (@{$opts->{path}}) {
        log_debug { 'Updating path "' . $path . '"' };

        $path = eval { ps_parse($path) };
        die_fatal "Failed to parse path ($@)", 4 if ($@);

        my @places = eval { spath($data, $path, expand => 1) };
        die_fatal "Failed to resolve path ($@)", 4 if ($@);

        for my $place (@places) {
            $$place = $opts->{value};
        }
    }
}


1; # End of NDTools::NDProc::Module::Insert

__END__

=head1 NAME

Insert - insert structure/value into another structure

=head1 OPTIONS

=over 4

=item B<--file|-f> E<lt>fileE<gt>

Load structure from file.

=item B<--path> E<lt>pathE<gt>

Path in the structure to deal with. May be used several times.

=item B<--value> E<lt>valueE<gt>

Value to insert. Meaningless when --file opt used.

=back

=head1 SEE ALSO

L<ndproc(1)>, L<ndproc-modules>

L<nddiff(1)>, L<ndquery(1)>, L<Struct::Path::PerlStyle>

