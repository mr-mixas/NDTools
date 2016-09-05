package NDTools::NDDiff;

use strict;
use warnings FATAL => 'all';

use NDTools::INC;
use NDTools::Slurp qw(st_dump st_load);
use Log::Log4Cli;
use Struct::Diff qw();
use Struct::Path qw(spath spath_delta);
use Struct::Path::PerlStyle qw(ps_parse);
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
}

sub dump {
    my $self = shift;
    if ($self->{OPTS}->{'out-fmt'} eq 'human') {
        my $t_opts = {
            callback => sub { $self->print_status_block(@_) },
            sortkeys => 1,
            statuses => [ qw{R O N A} ],
        };
        Struct::Diff::dtraverse($self->{diff}, $t_opts);
    } else {
        st_dump(\*STDOUT, $self->{diff}, $self->{OPTS}->{'out-fmt'});
    }
    return 1
}

sub load {
    my $self = shift;
    die_fatal "Two arguments expected for diff", 1 unless (@ARGV == 2);
    for my $i (@ARGV) {
        my $data = st_load($i, undef) or return undef;
        if (my $path = $self->{OPTS}->{path}) {
            $path = eval_fatal { ps_parse($path) } 1, "Failed to parse path '$path'";
            ($data) = spath($data, $path, deref => 1);
        }
        push @{$self->{items}}, $data;
    }
    return 1;
}

sub post_diff {
    return 1
}

sub pre_diff {
    return 1
}

sub print_status_block {
    my ($self, $value, $path, $status) = @_;
    my @lines;
    my $color = $self->{'OPTS'}->{'human'}->{'line'}->{$status};

    # diff for path
    if (@{$path} and my @delta = spath_delta($self->{'hdr_path'}, $path)) {
        $self->{'hdr_path'} = [@{$path}];

        my $header;
        my $indent = "";

        unless ($self->{OPTS}->{'full-headers'}) {
            $indent = sprintf "%" . (@{$path} - @delta) * 2 . "s", "";
            $path = \@delta;
        }

        $path = [ map { ref $_ eq 'ARRAY' ? [0] : $_ } @{$path} ]; # don't inflate arrays for headers
        spath(\$header, $path, expand => 1);       # wrap path into nested structure
        $header = substr Dump($header), 4;         # convert to YAML and cut off it's header
        $header = substr($header, 0, -3);          # cut off trailing 'undef'

        @lines = map { "  " . $indent . $_ } split("\n", $header);
        if ($status eq 'A' or $status eq 'R') {
            substr $lines[-1], 0, 1, $self->{'OPTS'}->{'human'}->{'sign'}->{$status};
            $lines[-1] = colored($lines[-1], $color) if ($self->{OPTS}->{colors});
        }
    }

    # diff for value
    my $pfx = $self->{'OPTS'}->{'human'}->{'sign'}->{$status} . " ";
    $pfx .= sprintf "%" . @{$self->{'hdr_path'}} * 2 . "s", "";
    for my $line (split("\n", substr(Dump($value), 4))) {
        push @lines, $self->{OPTS}->{colors} ? colored($pfx . $line, $color) : $pfx . $line;
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

1; # End of NDTools::NDDiff
