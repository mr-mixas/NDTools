package NDTools::NDDiff;

use strict;
use warnings FATAL => 'all';

use Algorithm::Diff;
use NDTools::INC;
use NDTools::Slurp qw(st_dump st_load);
use Log::Log4Cli;
use Struct::Diff qw();
use Struct::Path qw(spath spath_delta);
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);
use Term::ANSIColor qw(colored);
use YAML::XS qw(Dump);
use Pod::Find qw(pod_where);
use Pod::Usage;

sub MODINFO { die_fatal "Method 'MODINFO' must be overrided!" }
sub MODNAME { die_fatal "Method 'MODNAME' must be overrided!" }
sub VERSION { die_fatal "Method 'VERSION' must be overrided!" }

sub opts_def { # Getopt::Long options
    'full-headers',
    'out-fmt=s',
    'path=s'
}

sub defaults {
    my $out = {
        'out-fmt' => 'human',
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
    };
    $out->{human}{line}{N} = $out->{human}{line}{A};
    $out->{human}{line}{O} = $out->{human}{line}{R};
    $out->{human}{sign}{N} = $out->{human}{sign}{A};
    $out->{human}{sign}{O} = $out->{human}{sign}{R};
    return $out;
}

sub new {
    my ($class, %opts) = @_;
    my $self = { OPTS => { %{(defaults)}, %opts }};
    $self->{OPTS}->{colors} = -t STDOUT ? 1 : 0;
    return bless $self, $class;
}

sub diff {
    my $self = shift;
    $self->{diff} = Struct::Diff::diff($self->{items}->[0], $self->{items}->[1]);
    if ($self->{OPTS}->{'out-fmt'} eq 'human') {
        $self->_diff_texts or return undef;
    }
    return $self->{diff};
}

sub dump {
    my $self = shift;
    if ($self->{OPTS}->{'out-fmt'} eq 'human') {
        my $t_opts = {
            callback => sub { $self->print_status_block(@_) },
            sortkeys => 1,
            statuses => [ qw{R O N A Algorithm::Diff::sdiff} ],
        };
        Struct::Diff::dtraverse($self->{diff}, $t_opts);
    } else {
        st_dump(\*STDOUT, $self->{diff}, $self->{OPTS}->{'out-fmt'});
    }
    return 1
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
        push @{$self->{items}}, $data;
    }
    return 1;
}

sub load_uri {
    my ($self, $uri) = @_;
    st_load($uri, undef) or return undef;
}

sub post_diff {
    return 1
}

sub pre_diff {
    return 1
}

sub print_status_block {
    my ($self, $value, $path, $status) = @_;
    log_trace { ps_serialize($path) . ", " . $status . ":"};

    my @lines;
    my $color = $self->{'OPTS'}->{'human'}->{'line'}->{$status};

    # diff for path
    if (@{$path} and my @delta = spath_delta($self->{'hdr_path'}, $path)) {
        $self->{'hdr_path'} = [@{$path}];

        my $hpath = [@{$path}];
        my $hindt = 0;

        if (not $self->{OPTS}->{'full-headers'} and @delta != @{$path}) {
            my @path_pfx = @{$path}[0 .. @{$path} - @delta - 1];
            $hindt = (ref $delta[0] eq 'ARRAY' or ref $path_pfx[-1] eq 'ARRAY')
                ? @path_pfx - 1 : @path_pfx;
            $hpath = \@delta;
        }
        pop @{$hpath} if (ref $hpath->[-1] eq 'ARRAY');

        if (@{$hpath}) {
            $hindt = sprintf "%" . $hindt * 2 . "s", "";

            my $header;
            $hpath = [ map { ref $_ eq 'ARRAY' ? [0] : $_ } @{$hpath} ]; # deflate arrays for headers
            spath(\$header, $hpath, expand => 1);      # wrap path into nested structure
            $header = substr Dump($header), 4;         # convert to YAML and cut off it's header
            $header = substr($header, 0, -3);          # cut off trailing 'undef'

            @lines = map { "  " . $hindt . $_ } split("\n", $header);
            if ($status eq 'A' or $status eq 'R') {
                substr $lines[-1], 0, 1, $self->{'OPTS'}->{'human'}->{'sign'}->{$status};
                $lines[-1] = colored($lines[-1], $color) if ($self->{OPTS}->{colors});
            }
        }
    }

    # diff for value
    my $dindt = sprintf "%" . (grep { ref $_ ne 'ARRAY' } @{$path}) * 2 . "s", "";
    $value = [ $value ] if (ref $path->[-1] eq 'ARRAY');

    if ($status eq 'Algorithm::Diff::sdiff') {
        push @lines, $self->_human_text_diff($value, $dindt);
    } else {
        my $pfx = $self->{OPTS}->{human}->{sign}->{$status} . " " . $dindt;
        for my $line (split("\n", substr(Dump($value), 4))) {
            push @lines, $self->{OPTS}->{colors} ?
                colored($pfx . $line, $color) :
                $pfx . $line;
        }
    }
    print join("\n", @lines) . "\n";
}

sub run {
    my $self = shift;
    $self->load(@ARGV) or return undef;
    $self->pre_diff;
    $self->diff or return undef;
    $self->post_diff;
    $self->dump or return undef;
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
                ${$r}->{'Algorithm::Diff::sdiff'} = Algorithm::Diff::sdiff(\@old, \@new);
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
