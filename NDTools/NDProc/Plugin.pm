package NDTools::NDProc::Plugin;

# base class for ndproc plugins

use strict;
use warnings FATAL => 'all';

use NDTools::INC;
use Getopt::Long qw(:config bundling nopass_through);
use Log::Log4Cli;
use Pod::Find qw(pod_where);
use Pod::Usage;

sub MODINFO { die_fatal "Method 'MODINFO' must be overrided!" }
sub VERSION { die_fatal "Method 'VERSION' must be overrided!" }

sub arg_opts {
    my $self = shift;
    return (
        'colors!' => \$self->{OPTS}->{'colors'},
        'help|h' => sub {
            pod2usage(-exitval => 1, -output => \*STDERR,
            -sections => 'SYNOPSIS|OPTIONS|EXAMPLES', -verbose => 99)
        },
    )
}

sub configure {
    my $self = shift;
    $self->{OPTS}->{'colors'} = -t STDOUT ? 1 : 0 unless (defined $self->{OPTS}->{'colors'});
}

sub defaults {
    return {
        enabled => 1,
    };
}

sub new {
    my $self = bless {}, shift;
    $self->{OPTS} = $self->defaults();
    unless (GetOptions ($self->arg_opts)) {
        $self->usage;
        return undef;
    }
    return $self;
}

sub process {
    log_fatal { "It works" };
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

1; # End of NDTools::NDProc::Plugin
