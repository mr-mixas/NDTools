package NDTools::NDProc::Module::Merge;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Module";

use NDTools::INC;
use Log::Log4Cli;
use NDTools::Struct qw(st_copy st_merge);
use Struct::Path qw(spath);
use Struct::Path::PerlStyle qw(ps_parse);

sub MODINFO { "Merge structures according provided rules" }
sub VERSION { "0.01" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'ignore=s@' => \$self->{OPTS}->{ignore},
        'merge=s'   => sub { push @{$self->{OPTS}->{merge}}, {path => $_[1]} },
        'source=s@' => \$self->{OPTS}->{source}, # will be resolved if multiple times used
        'strict!'   => \$self->{OPTS}->{strict},
        'style=s'   => sub {
            if (exists $self->{OPTS}->{merge} and @{$self->{OPTS}->{merge}}) {
                $self->{OPTS}->{merge}->[-1]->{style} = $_[1];
            } else {
                $self->{OPTS}->{style} = $_[1];
            }
        },
    )
}

sub defaults {
    my $self = shift;
    return {
        %{$self->SUPER::defaults()},
        'style' => 'R_OVERRIDE',
    };
}

sub process {
    my ($self, $data, $opts, $source) = @_;

    if (exists $opts->{ignore}) {
        for my $path (@{$opts->{ignore}}) {
            log_debug { "Ignoring '$path'" };
            spath($source, ps_parse($path), delete => 1);
        }
    }

    map { unshift @{$opts->{merge}}, { path => $_ } } splice @{$opts->{path}}
        if ($opts->{path}); # use merges specified via path as first merge subrules
    # merge full source if no paths defined
    push @{$opts->{merge}}, {} unless ($opts->{merge} and @{$opts->{merge}});

    for my $m (@{$opts->{merge}}) {
        $m->{path} = '' unless (defined $m->{path}); # merge whole source if path omitted
        my $style = $m->{style} || $opts->{style} || $self->{style};
        my $subst = st_copy($source, ps_parse($m->{path}));

        log_info { "Merging $opts->{source} ($style, $m->{path})" };
        ${$data} = st_merge(${$data}, $subst, style => $style);
    }
}


1; # End of NDTools::NDProc::Module::Merge

__END__

=head1 NAME

Merge - merge structures according provided rules

=head1 OPTIONS

=over 4

=item B<--ignore> E<lt>pathE<gt>

Skip specified structure parts. May be used several times.

=item B<--merge> E<lt>pathE<gt>

Path in the structure to merge. Whole structure will be merged if
omitted. Paths '' or '{}' or '[]' means "whole" struct, and should be
used as first merge target if whole struct must be merged and then
some parts merged with other options. May be specified several times.

=item B<--source> E<lt>uriE<gt>

Source to merge with.

=item B<--[no]strict>

Fail if specified path doesn't exists in prerequisite. Enabled by default.

=item B<--style> E<lt>styleE<gt>

Merge style. Positional opt - define rule default if used before --merge,
per-merge opt otherwise.

=over 8

=item B<L_OVERRIDE>, B<R_OVERRIDE>

Objects merged, lists and scalars overrided, left and right precedence.

=back

Default is B<R_OVERRIDE>

=back

=head1 SEE ALSO

L<ndproc(1)>, L<ndproc-modules(1)>

L<nddiff(1)>, L<ndquery(1)>, L<Struct::Path::PerlStyle>

