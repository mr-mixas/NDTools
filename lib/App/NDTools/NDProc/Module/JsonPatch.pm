package App::NDTools::NDProc::Module::JsonPatch;

use strict;
use warnings FATAL => 'all';
use parent 'App::NDTools::NDProc::Module';

use App::NDTools::Util qw(chomp_evaled_error);
use JSON::Patch 0.04 qw(patch);
use Log::Log4Cli;
use Struct::Path 0.80 qw(path);

our $VERSION = '0.01';

sub MODINFO { "Apply JSON Patch (rfc6902) patches" }

sub arg_opts {
    my $self = shift;

    return (
        $self->SUPER::arg_opts(),
        'source=s'  => \$self->{OPTS}->{source},
        'strict!'   => \$self->{OPTS}->{strict},
    )
}

sub check_rule {
    my ($self, $rule) = @_;

    die_fatal "Source file should be specified", 1
        unless ($rule->{source});

    push @{$rule->{path}}, '' unless (@{$rule->{path}});

    return $self;
}

sub configure {
    my $self = shift;

    # to prevent source resolve to target (ndproc defaults)
    delete $self->{OPTS}->{source}
        unless (defined $self->{OPTS}->{source});
}

sub process_path {
    my ($self, $data, $path, $spath, $opts, $source) = @_;

    my @refs = eval { path(${$data}, $spath, strict => $opts->{strict}) };
    die_fatal "Failed to lookup path '$path'", 4 if ($@);

    for (@refs) {
        eval { patch(${$_}, $source) };
        die_fatal chomp_evaled_error($@), 8 if ($@);
    }
}

1; # End of App::NDTools::NDProc::Module::JsonPatch

__END__

=head1 NAME

Patch - Apply JSON Patch (rfc6902) patches

=head1 OPTIONS

=over 4

=item B<--[no]blame>

Blame calculation toggle. Enabled by default.

=item B<--path> E<lt>pathE<gt>

Path in the structure to patch. May be used several times. Whole structure
will be patched if omitted or empty.

=item B<--preserve> E<lt>pathE<gt>

Preserve specified substructure. May be used several times.

=item B<--source> E<lt>uriE<gt>

Source containing patch.

=item B<--strict>

Fail if path specified for patch doesn't exist.

=back

=head1 SEE ALSO

L<ndproc>, L<ndproc-modules>

L<nddiff>, L<ndquery>, L<Struct::Path::PerlStyle>
