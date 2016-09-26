package NDTools::NDDiff;

use strict;
use warnings FATAL => 'all';

use Algorithm::Diff;
use Getopt::Long qw(:config bundling nopass_through);
use JSON qw(to_json);
use NDTools::INC;
use NDTools::Slurp qw(s_dump st_load);
use Log::Log4Cli;
use Struct::Diff qw();
use Struct::Path qw(spath spath_delta);
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);
use Term::ANSIColor qw(colored);
use Pod::Find qw(pod_where);
use Pod::Usage;

sub MODINFO { die_fatal "Method 'MODINFO' must be overrided!" }
sub VERSION { die_fatal "Method 'VERSION' must be overrided!" }

sub arg_opts {
    my $self = shift;
    return (
        'colors!' => \$self->{OPTS}->{'colors'},
        'full-headers' => \$self->{OPTS}->{'full-headers'},
        'json' => sub { $self->{OPTS}->{'out-fmt'} = $_[0]},
        'out-fmt=s' => \$self->{OPTS}->{'out-fmt'},
        'path=s' => \$self->{OPTS}->{path},
        'quiet|q' => \$self->{OPTS}->{quiet},
    )
}

sub defaults {
    my $out = {
        'human' => {
            'line' => {
                'A' => 'green',
                'D' => 'yellow',
                'U' => 'white',
                'R' => 'red',
            },
            'sign' => {
                'A' => '>',
                'D' => '!',
                'U' => ' ',
                'R' => '<',
            },
        },
        'out-fmt' => 'human',
    };
    $out->{human}{line}{N} = $out->{human}{line}{A};
    $out->{human}{line}{O} = $out->{human}{line}{R};
    $out->{human}{sign}{N} = $out->{human}{sign}{A};
    $out->{human}{sign}{O} = $out->{human}{sign}{R};
    return $out;
}

sub new {
    my $self = bless { OPTS => defaults }, shift;
    unless (GetOptions ($self->arg_opts)) {
        $self->usage;
        return undef;
    }
    $self->{OPTS}->{'colors'} = -t STDOUT ? 1 : 0
        unless (defined $self->{OPTS}->{'colors'});
    return $self;
}

sub add {
    my $self = shift;
    push @{$self->{items}}, @_;
}

sub diff {
    my $self = shift;
    log_debug { "Calculating diff for structure" };
    $self->{diff} = Struct::Diff::diff($self->{items}->[0], $self->{items}->[1]);
    if ($self->{OPTS}->{'out-fmt'} eq 'human') {
        $self->_diff_texts or return undef;
    }
    return $self->{diff};
}

sub dump {
    my $self = shift;
    log_debug { "Dumping results" };
    if ($self->{OPTS}->{'out-fmt'} eq 'human') {
        my $t_opts = {
            callback => sub { $self->print_status_block(@_) },
            sortkeys => 1,
            statuses => [ qw{R O N A TEXT_SDIFF} ],
        };
        Struct::Diff::dtraverse($self->{diff}, $t_opts);
    } else {
        s_dump(\*STDOUT, $self->{OPTS}->{'out-fmt'}, undef, $self->{diff});
    }
    return 1
}

sub list {
    my $self = shift;
    return @{$self->{items}};
}

sub load {
    my $self = shift;
    die_fatal "Two arguments expected for diff", 1 unless (@_ == 2);
    for my $i (@_) {
        my $data = $self->load_uri($i) or return undef;
        if (my $path = $self->{OPTS}->{path}) {
            $path = eval_fatal { ps_parse($path) } 1, "Failed to parse path '$path'";
            ($data) = spath($data, $path, deref => 1);
        }
        $self->add($data);
    }
    return 1;
}

sub load_uri {
    my ($self, $uri) = @_;
    log_debug { "Loading $uri" };
    st_load($uri, undef) or return undef;
}

sub print_status_block {
    my ($self, $value, $path, $status) = @_;
    log_trace { ps_serialize($path) . ", " . $status . ":"};

    my @lines;
    my $color = $self->{'OPTS'}->{'human'}->{'line'}->{$status};
    my $dsign = $self->{'OPTS'}->{'human'}->{'sign'}->{$status};

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
    if ($status eq 'TEXT_SDIFF') {
        push @lines, $self->_human_text_diff($value, $indt);
    } else {
        $value = to_json($value, {allow_nonref => 1, canonical => 1, pretty => 0})
            if (ref $value or not defined $value);
        for my $line (split("\n", $value)) {
            $line = "$dsign $indt" . $line;
            $line = colored($line, $color) if ($self->{OPTS}->{colors});
            push @lines, $line;
        }
    }

    print join("\n", @lines) . "\n";
}

sub run {
    my $self = shift;
    $self->load(@ARGV) or return undef;
    $self->diff or return undef;
    $self->dump or return undef unless ($self->{OPTS}->{quiet});
}

sub status {
    my $self = shift;
    return 250 unless (exists $self->{diff});
    return 0 if (keys $self->{diff} == 0 or exists $self->{diff}->{U});
    return 8; # differences found
}

sub usage {
    pod2usage(
        -exitval => 'NOEXIT',
        -input => pod_where({-inc => 1}, ref(shift)),
        -output => \*STDERR,
        -sections => 'SYNOPSIS|OPTIONS|EXAMPLES',
        -verbose => 99
    );
}

sub _diff_texts {
    my $self = shift;
    log_debug { "Calculating diffs for text values" };
    my $diff = $self->{diff};
    my $t_opts = {
        callback => sub {
            my ($v, $p, $s, $r) = @_; # value, path, status, diff_ref
            unless (exists ${$r}->{O}) {
                log_error { "Incomplete diff passed (old value doesn't exists)" };
                return undef;
            }
            my (@old, @new);
            @old = split(/$\//, ${$r}->{O}) if (${$r}->{O} and not ref ${$r}->{O});
            @new = split(/$\//, ${$r}->{N}) if (${$r}->{N} and not ref ${$r}->{N});
            if (@old > 1 or @new > 1) {
                ${$r}->{'TEXT_SDIFF'} = Algorithm::Diff::sdiff(\@old, \@new);
                delete ${$r}->{O};
                delete ${$r}->{N};
            }
            return 1;
        },
        statuses => [ 'N' ],
    };
    Struct::Diff::dtraverse($self->{diff}, $t_opts);
}

sub _human_text_diff {
    my ($self, $val, $ind) = @_;
    my %colors = (
        '-' => $self->{OPTS}->{human}->{line}->{R},
        '+' => $self->{OPTS}->{human}->{line}->{A},
        'u' => $self->{OPTS}->{human}->{line}->{U},
    );
    my %signs = (
        '-' => $self->{OPTS}->{human}->{sign}->{R},
        '+' => $self->{OPTS}->{human}->{sign}->{A},
        'u' => $self->{OPTS}->{human}->{sign}->{U},
    );
    my @out;

    for my $line (@{$val}) {
        if ($line->[0] eq 'c') {
            push @out, $self->{OPTS}->{colors} ? # removed
                colored($signs{'-'} . " " . $ind . $line->[1], $colors{'-'}) :
                $signs{'-'} . " " . $ind . $line->[1];
            push @out, $self->{OPTS}->{colors} ? # added
                colored($signs{'+'} . " " . $ind . $line->[2], $colors{'+'}) :
                $signs{'+'} . " " . $ind . $line->[2];
            next;
        }
        my $str = ($line->[0] eq '+') ? $line->[2] : $line->[1];
        push @out, $self->{OPTS}->{colors} ?
            colored($signs{$line->[0]} . " " . $ind . $str, $colors{$line->[0]}) :
            $signs{$line->[0]} . " " . $ind . $str;
    }

    return @out;
}

1; # End of NDTools::NDDiff
