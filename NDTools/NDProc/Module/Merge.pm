package NDTools::NDProc::Module::Merge;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Module";

use NDTools::INC;
use Hash::Merge qw();
use NDTools::HMBehs qw();
use List::MoreUtils qw(before);
use Log::Log4Cli;
use Struct::Path qw(is_implicit_step spath);
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);

sub MODINFO { "Merge structures according provided rules" }
sub VERSION { "0.10" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'ignore=s@' => \$self->{OPTS}->{ignore},
        'merge|path=s' => sub { push @{$self->{OPTS}->{path}}, {merge => $_[1]} },
        'source=s@' => \$self->{OPTS}->{source}, # will be resolved if multiple times used
        'strict!'   => sub {
            if (exists $self->{OPTS}->{path} and @{$self->{OPTS}->{path}}) {
                $self->{OPTS}->{path}->[-1]->{strict} = $_[1];
            } else {
                $self->{OPTS}->{strict} = $_[1]
            }
         },
        'preserve=s@' => \$self->{OPTS}->{preserve},
        'style=s'   => sub {
            if (exists $self->{OPTS}->{path} and @{$self->{OPTS}->{path}}) {
                $self->{OPTS}->{path}->[-1]->{style} = $_[1];
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
        'strict' => 1,
        'style' => 'R_OVERRIDE',
    };
}

sub map_paths {
    my ($data, $srcs, $spath) = @_;

    my @explicit = before { is_implicit_step($_) } @{$spath};
    return spath($data, $spath, paths => 1, expand => 1)
        if (@explicit == @{$spath}); # fully qualified path

    my @out;
    my @dsts = spath($data, $spath, paths => 1);

    for my $src (@{$srcs}) {
        if (@dsts) { # destination struct may match - use this paths beforehand
            push @out, shift @dsts;
            next;
        }

        my @e_path = @{$spath};
        while (my $step = pop @e_path) {
            if (ref $step eq 'ARRAY' and is_implicit_step($step)) {
                if (my @tmp = spath($data, \@e_path, deref => 1, paths => 1)) {
                    # expand last existed array, addressed by implicit step
                    @e_path = ( @{$tmp[0][0]}, [ scalar @{$tmp[0][1]} ] );
                    last;
                }
            } elsif (ref $step eq 'HASH' and is_implicit_step($step)) {
                if (my @tmp = spath($data, [ @e_path, $step ], paths => 1)) {
                    @e_path = @{$tmp[0][0]};
                    last;
                }
            }
        }

        @e_path = @{$src->[0]}[0 .. $#explicit] unless (@e_path);
        my @i_path = @{$src->[0]}[@e_path .. $#{$src->[0]}];

        map { $_ = [0] if (ref $_ eq 'ARRAY') } @i_path; # drop array's indexes in implicit part of path
        my $dst = (spath($data, [@e_path, @i_path], paths => 1, expand => 1))[0];

        push @out, $dst;
    }

    return @out;
}

sub process {
    my ($self, $data, $opts, $source) = @_;

    if (exists $opts->{ignore}) {
        for my $path (@{$opts->{ignore}}) {
            log_debug { "Removing (ignore) from src '$path'" };
            spath($source, ps_parse($path), delete => 1);
        }
    }

    $self->stash_preserved($data, $opts->{preserve}) if ($opts->{preserve});

    # merge full source if no paths defined
    push @{$opts->{path}}, {} unless ($opts->{path} and @{$opts->{path}});
    # convert to canonical structure
    map { $_ = { merge => $_ } unless (ref $_) } @{$opts->{path}};

    for my $m (@{$opts->{path}}) {
        $m->{merge} = '' unless (defined $m->{merge}); # merge whole source if path omitted
        my $spath = ps_parse($m->{merge});

        log_debug { "Resolving paths '$m->{merge}'" };
        my @srcs = spath($source, $spath, paths => 1);
        unless (@srcs) {
            die_fatal "No such path ($m->{merge}) in $opts->{source}", 4
                if(exists $m->{strict} ? $m->{strict} : $opts->{strict});
            log_info { "Ignoring path $m->{merge} (doesn't exists in $opts->{source})" };
            next;
        }
        my @dsts = map_paths($data, \@srcs, $spath);

        my $style = $m->{style} || $opts->{style} || $self->{OPTS}->{style};
        for my $src (@srcs) {
            my $dst = shift @dsts;
            log_info { "Merging $opts->{source} ($style, '" .
                ps_serialize($src->[0]) . "' => '" . ps_serialize($dst->[0]) . "')" };
            Hash::Merge::set_behavior($style);
            ${$dst->[1]} = Hash::Merge::merge(${$dst->[1]}, ${$src->[1]});
        }
    }

    $self->restore_preserved($data) if ($opts->{preserve});
}

1; # End of NDTools::NDProc::Module::Merge

__END__

=head1 NAME

Merge - merge structures according provided rules

=head1 OPTIONS

=over 4

=item B<--[no]blame>

Blame calculaton toggle. Enabled by default.

=item B<--ignore> E<lt>pathE<gt>

Ignore part from source structure. Rule-wide option. May be used several times.

=item B<--merge> E<lt>pathE<gt>

Path in the source structure to merge. Whole structure will be merged if
omitted or empty. May be specified several times.

=item B<--preserve> E<lt>pathE<gt>

Preserve specified parts from original structure. Rule-wide option. May be used
several times.

=item B<--source> E<lt>uriE<gt>

Source to merge with. Original processing structure will be used if option
specified, but value not defined or empty. Rule-wide option. May be used several
times.

=item B<--[no]strict>

Fail if specified path doesn't exists in source structure. Positional opt - define
rule default if used before --merge, per-merge opt otherwise. Enabled by default.

=item B<--style> E<lt>styleE<gt>

Merge style. Positional option - define rule default if used before --merge,
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

