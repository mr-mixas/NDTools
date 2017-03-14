package NDTools::NDProc::Module;

# base class for ndproc modules

use strict;
use warnings FATAL => 'all';

use NDTools::INC;
use NDTools::Slurp qw(s_load);
use Getopt::Long qw(:config bundling pass_through);
use Log::Log4Cli;
use Pod::Find qw(pod_where);
use Pod::Usage;

sub MODINFO { "n/a" }
sub VERSION { "n/a" }

sub arg_opts {
    my $self = shift;
    return (
        'blame!' => \$self->{OPTS}->{blame}, # just to set opt in rule
        'help|h' => sub { $self->usage(); die_info undef, 0 },
        'path=s@' => \$self->{OPTS}->{path},
        'version|V' => sub { print $self->VERSION . "\n"; die_info undef, 0; },
    )
}

sub configure {
    my $self = shift;
}

sub defaults {
    return {
        disabled => undef,
        path => [],
    };
}

sub get_opts {
    my $self = shift;
    return $self->{OPTS};
}

sub load_uri {
    my ($self, $uri) = @_;
    log_debug { "Loading $uri" };
    s_load($uri, undef) or return undef;
}

sub new {
    my $self = bless {}, shift;
    $self->{OPTS} = $self->defaults();
    $self->configure;
    return $self;
}

sub parse_args {
    my $self = shift;
    unless (GetOptions ($self->arg_opts)) {
        $self->usage;
        die_fatal "Unsupported opt passed", 1;
    }
    $self->configure;
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
        -sections => 'NAME|DESCRIPTION|OPTIONS',
        -verbose => 99
    );
}

1; # End of NDTools::NDProc::Module
