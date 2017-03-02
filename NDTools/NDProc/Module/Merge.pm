package NDTools::NDProc::Module::Merge;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Module";

use NDTools::INC;
use List::MoreUtils qw(before);
use Log::Log4Cli;
use NDTools::Struct qw(st_copy st_merge);
use Struct::Path qw(spath);
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);

sub MODINFO { "Merge structures according provided rules" }
sub VERSION { "0.05" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'ignore=s@' => \$self->{OPTS}->{ignore},
        'merge=s'   => sub { push @{$self->{OPTS}->{merge}}, {path => $_[1]} },
        'source=s@' => \$self->{OPTS}->{source}, # will be resolved if multiple times used
        'strict!'   => sub {
            if (exists $self->{OPTS}->{merge} and @{$self->{OPTS}->{merge}}) {
                $self->{OPTS}->{merge}->[-1]->{strict} = $_[1];
            } else {
                $self->{OPTS}->{strict} = $_[1]
            }
         },
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
        'strict' => 1,
        'style' => 'R_OVERRIDE',
    };
}

sub is_implicit_step {
    my $step = shift;

    if (ref $step eq 'ARRAY') {
        return 1 unless @{$step};
    } elsif (ref $step eq 'HASH') {
        return 1 if (exists $step->{keys} and not @{$step->{keys}});
        return 1 if (exists $step->{regs} and @{$step->{regs}});
    } else { # coderefs
        return 1;
    }

    return undef;
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
        my $spath = ps_parse($m->{path});

        log_debug { "Resolving paths '$m->{path}'" };
        my @srcs = spath($source, $spath, paths => 1);
        unless (@srcs) {
            die_fatal "No such path ($m->{path}) in $opts->{source}", 4
                if(exists $m->{strict} ? $m->{strict} : $opts->{strict});
            log_info { "Ignoring path $m->{path} (doesn't exists in $opts->{source})" };
            next;
        }
        my @dsts = map_paths($data, \@srcs, $spath);

        my $style = $m->{style} || $opts->{style} || $self->{OPTS}->{style};
        for my $src (@srcs) {
            my $dst = shift @dsts;
            log_info { "Merging $opts->{source} ($style, '" .
                ps_serialize($src->[0]) . "' => '" . ps_serialize($dst->[0]) . "')" };
            ${$dst->[1]} = st_merge(${$dst->[1]}, ${$src->[1]}, style => $style);
        }
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

Source to merge with. Processing structure will be used if not defined or
empty string used.

=item B<--[no]strict>

Fail if specified path doesn't exists in prerequisite. Positional - define
rule default if used before --merge, per-merge opt otherwise. Enabled by default.

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

