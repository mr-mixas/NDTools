package NDTools::NDDiff;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDTool";

use Algorithm::Diff;
use JSON qw(to_json);
use NDTools::INC;
use NDTools::Slurp qw(s_dump s_load);
use Log::Log4Cli;
use Struct::Diff qw();
use Struct::Path qw(spath spath_delta);
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);
use Term::ANSIColor qw(colored);

sub VERSION { "0.14" }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'brief' => sub { $self->{OPTS}->{'out-fmt'} = $_[0] },
        'colors!' => \$self->{OPTS}->{colors},
        'ctx-text=i' => \$self->{OPTS}->{'ctx-text'},
        'full' => \$self->{OPTS}->{full},
        'full-headers' => \$self->{OPTS}->{'full-headers'},
        'json' => sub { $self->{OPTS}->{'out-fmt'} = $_[0] },
        'ignore=s@' => \$self->{OPTS}->{ignore},
        'out-fmt=s' => \$self->{OPTS}->{'out-fmt'},
        'path=s' => \$self->{OPTS}->{path},
        'quiet|q' => \$self->{OPTS}->{quiet},
        'show' => \$self->{OPTS}->{show},
    )
}

sub configure {
    my $self = shift;
    $self->{OPTS}->{colors} = -t STDOUT ? 1 : 0 unless (defined $self->{OPTS}->{colors});
}

sub defaults {
    my $self = shift;
    my $out = {
        %{$self->SUPER::defaults()},
        'ctx-text' => 3,
        'term' => {
            'line' => {
                'A' => 'green',
                'D' => 'yellow',
                'U' => 'white',
                'R' => 'red',
                '@' => 'magenta',
            },
            'sign' => {
                'A' => '>',
                'D' => '!',
                'U' => ' ',
                'R' => '<',
                '@' => ' ',
            },
        },
        'out-fmt' => 'term',
    };
    $out->{term}{line}{N} = $out->{term}{line}{A};
    $out->{term}{line}{O} = $out->{term}{line}{R};
    $out->{term}{sign}{N} = $out->{term}{sign}{A};
    $out->{term}{sign}{O} = $out->{term}{sign}{R};
    return $out;
}

sub add {
    my $self = shift;
    push @{$self->{items}}, @_;
}

sub diff {
    my $self = shift;
    log_debug { "Calculating diff for structure" };
    $self->{diff} = Struct::Diff::diff(
        $self->{items}->[0],
        $self->{items}->[1],
        noU => $self->{OPTS}->{full} ? 0 : 1,
    );
    if ($self->{OPTS}->{'out-fmt'} eq 'term') {
        $self->diff_texts or return undef;
    }
    return $self->{diff};
}

sub _lcsidx2ranges {
    my ($in_a, $in_b) = @_;
    my @out_a = [ shift @{$in_a} ];
    my @out_b = [ shift @{$in_b} ];

    while (@{$in_a} or @{$in_b}) {
        my $i_a = shift @{$in_a};
        my $i_b = shift @{$in_b};
        if (
            ($i_a - $out_a[-1][-1] < 2) and
            ($i_b - $out_b[-1][-1] < 2)
        ) { # update ranges - both sequences are continous
            $out_a[-1][1] = $i_a;
            $out_b[-1][1] = $i_b;
        } else { # new ranges
            push @out_a, [ $i_a ];
            push @out_b, [ $i_b ];
        }
    }

    return \@out_a, \@out_b;
}

sub diff_texts {
    my $self = shift;
    log_debug { "Calculating diffs for text values" };
    my $t_opts = {
        callback => sub {
            my ($v, $p, $s, $r) = @_; # value, path, status, diff_ref
            unless (exists ${$r}->{O}) {
                log_error { "Incomplete diff passed (old value doesn't exists)" };
                return undef;
            }

            my @old = split(/$\//, ${$r}->{O}) if (${$r}->{O} and not ref ${$r}->{O});
            my @new = split(/$\//, ${$r}->{N}) if (${$r}->{N} and not ref ${$r}->{N});

            if (@old > 1 or @new > 1) {
                delete ${$r}->{O};
                delete ${$r}->{N};

                my ($o, $n) = _lcsidx2ranges(Algorithm::Diff::LCSidx \@old, \@new);
                my ($po, $pn) = (0, 0); # current positions in splitted texts

                while (@{$o} or @{$n}) {
                    my ($ro, $rn) = (shift @{$o}, shift @{$n}); # current ranges (indexes for common sequence)
                    push @{${$r}->{T}}, { R => [ @old[$po .. $ro->[0] - 1] ] } if ($ro->[0] > $po);
                    push @{${$r}->{T}}, { A => [ @new[$pn .. $rn->[0] - 1] ] } if ($rn->[0] > $pn);
                    push @{${$r}->{T}}, { U => [ @new[$rn->[0] .. $rn->[-1]] ] };
                    $po = $ro->[-1] + 1;
                    $pn = $rn->[-1] + 1;
                }

                push @{${$r}->{T}}, { R => [ @old[$po .. $#old] ] } if ($po <= $#old); # collect tailing removed
                push @{${$r}->{T}}, { A => [ @new[$pn .. $#new] ] } if ($pn <= $#new); # collect tailing added
            }
            return 1;
        },
        statuses => [ 'N' ],
    };
    Struct::Diff::dtraverse($self->{diff}, $t_opts);
}

sub dump {
    my $self = shift;
    log_debug { "Dumping results" };
    if ($self->{OPTS}->{'out-fmt'} eq 'term') {
        my $t_opts = {
            callback => sub { $self->print_term_block(@_) },
            sortkeys => 1,
            statuses => [ qw{R O N A T} ],
        };
        Struct::Diff::dtraverse($self->{diff}, $t_opts);
    } elsif ($self->{OPTS}->{'out-fmt'} eq 'brief') {
        my $t_opts = {
            callback => sub { $self->print_brief_block(@_) },
            sortkeys => 1,
            statuses => [ qw{R N A} ],
        };
        Struct::Diff::dtraverse($self->{diff}, $t_opts);
    } else {
        s_dump(\*STDOUT, $self->{OPTS}->{'out-fmt'}, {pretty => $self->{OPTS}->{pretty}}, $self->{diff});
    }
    return 1
}

sub exec {
    my $self = shift;
    $self->load(@ARGV) or die_fatal undef, 1;
    if ($self->{OPTS}->{show}) {
        $self->{diff} = shift @{$self->{items}};
    } else {
        $self->diff or die_fatal undef, 1;
    }
    $self->dump or die_fatal undef, 1 unless ($self->{OPTS}->{quiet});

    die_info "All done, no difference found", 0
        if (not keys %{$self->{diff}} or exists $self->{diff}->{U});
    die_info "Difference found", 8;
}

sub list {
    my $self = shift;
    return @{$self->{items}};
}

sub load {
    my $self = shift;
    if ($self->{OPTS}->{show}) {
        die_fatal "One argument expected (--show) used", 1 unless (@_ == 1);
    } else {
        die_fatal "Two arguments expected for diff", 1 unless (@_ == 2);
    }

    for my $i (@_) {
        my $data = $self->load_uri($i) or return undef;
        if (my $path = $self->{OPTS}->{path}) {
            my $p = eval { ps_parse($path) };
            if ($@) {
                log_error { "Failed to parse path '$path' ($@)" };
                return undef;
            }
            ($data) = spath($data, $p, deref => 1);
        }
        if (exists $self->{OPTS}->{ignore}) {
            for my $path (@{$self->{OPTS}->{ignore}}) {
                my $p = eval { ps_parse($path) };
                if ($@) {
                    log_error { "Failed to parse path '$path' ($@)" };
                    return undef;
                }
                spath($data, $p, delete => 1);
            }
        }
        $self->add($data);
    }
    return 1;
}

sub load_uri {
    my ($self, $uri) = @_;
    log_debug { "Loading $uri" };
    s_load($uri, undef) or return undef;
}

sub print_brief_block {
    my ($self, $value, $path, $status) = @_;

    return unless (@{$path}); # nothing to show

    $path = [ @{$path} ]; # prevent passed path corruption (used later for items with same subpath)
    $status = 'D' if ($status eq 'N');
    my $last = ps_serialize([pop @{$path}]);
    my $base = ps_serialize($path);

    if ($self->{OPTS}->{colors}) {
        $last = colored($last, "bold " . $self->{OPTS}->{term}->{line}->{$status});
        $base = colored($base, $self->{OPTS}->{term}->{line}->{U});
    }

    print $self->{OPTS}->{term}->{sign}->{$status} . " " . $base . $last . "\n";
}

sub print_term_block {
    my ($self, $value, $path, $status) = @_;
    log_trace { "'" . ps_serialize($path) . "' (" . $status . ")"};

    my @lines;
    my $color = $self->{OPTS}->{term}->{line}->{$status};
    my $dsign = $self->{OPTS}->{term}->{sign}->{$status};

    # diff for path
    if (@{$path} and my @delta = spath_delta($self->{'hdr_path'}, $path)) {
        $self->{'hdr_path'} = [@{$path}];
        for (my $s = 0; $s < @{$path}; $s++) {
            next if (not $self->{OPTS}->{'full-headers'} and $s < @{$path} - @delta);
            my $line = sprintf("%" . $s * 2 . "s", "") . ps_serialize([$path->[$s]]);
            if (($status eq 'A' or $status eq 'R') and $s == $#{$path}) {
                $line = "$dsign $line";
                $line = colored($line, "bold $color") if ($self->{OPTS}->{colors});
            } else {
                $line = "  $line";
            }
            push @lines, $line;
        }
    }

    # diff for value
    my $indt = sprintf "%" . @{$path} * 2 . "s", "";
    if ($status eq 'T') {
        push @lines, $self->term_text_diff($value, $indt);
    } else {
        $value = to_json($value, {allow_nonref => 1, canonical => 1, pretty => $self->{OPTS}->{pretty}})
            if (ref $value or not defined $value);
        for my $line (split("\n", $value)) {
            $line = "$dsign $indt" . $line;
            $line = colored($line, $color) if ($self->{OPTS}->{colors});
            push @lines, $line;
        }
    }

    print join("\n", @lines) . "\n";
}

sub term_text_diff {
    my ($self, $diff, $indent) = @_;
    my (@out, @head_ctx, @tail_ctx, $pos);

    while (my $hunk = shift @{$diff}) {
        my ($status, $lines) = each %{$hunk};
        my $sign  = $self->{OPTS}->{term}->{sign}->{$status};
        my $color = $self->{OPTS}->{term}->{line}->{$status};
        $pos += @{$lines};

        if ($status eq 'U') {
            if ($self->{OPTS}->{'ctx-text'}) {
                @head_ctx = splice(@{$lines});                                  # before changes
                @tail_ctx = splice(@head_ctx, 0, $self->{OPTS}->{'ctx-text'})   # after changes
                    if (@out);
                splice(@head_ctx, 0, @head_ctx - $self->{OPTS}->{'ctx-text'})
                    if (@head_ctx > $self->{OPTS}->{'ctx-text'});

                splice(@head_ctx) unless (@{$diff});

                @head_ctx = map {
                    my $l = $sign . " " . $indent . $_;
                    $self->{OPTS}->{colors} ? colored($l, $color) : $l;
                } @head_ctx;
                @tail_ctx = map {
                    my $l = $sign . " " . $indent . $_;
                    $self->{OPTS}->{colors} ? colored($l, $color) : $l;
                } @tail_ctx;
            } else {
                splice(@{$lines}); # purge or will be printed in the next block
            }
        }

        push @out, splice @tail_ctx;
        if (@head_ctx or (not $self->{OPTS}->{'ctx-text'} and $status eq 'U' and @{$diff}) or not @out) {
            my $l = $self->{OPTS}->{term}->{sign}->{'@'} . " " . $indent . "@@ $pos,- -,- @@";
            push @out, $self->{OPTS}->{colors} ? colored($l, $self->{OPTS}->{term}->{line}->{'@'}) : $l;
        }
        push @out, splice @head_ctx;
        push @out, map {
            my $l = $sign . " " . $indent . $_;
            $self->{OPTS}->{colors} ? colored($l, $color) : $l;
        } @{$lines};
    }

    return @out;
}

1; # End of NDTools::NDDiff
