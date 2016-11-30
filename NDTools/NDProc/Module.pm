package NDTools::NDProc::Module;

# base class for ndproc modules

use strict;
use warnings FATAL => 'all';

use NDTools::INC;
use Getopt::Long qw(:config bundling pass_through);
use Log::Log4Cli;
use Module::Find;
use NDTools::NDProc::Processor;
use NDTools::Slurp qw(s_dump s_load);
use Pod::Find qw(pod_where);
use Pod::Usage;

use Data::Dumper; # debug only

sub VERSION { die_fatal "Method 'VERSION' must be overrided!" }

sub arg_opts {
    my $self = shift;
    return (
        'help|h' => sub { $self->usage; die_info undef, 1 },
        'list-modules|l' => \$self->{OPTS}->{'list-modules'},
        'module|m=s' => \$self->{OPTS}->{module},
        'rules=s' => sub { push @{$self->{rules}}, @{s_load($_[1], undef)} },
        'verbose|v:+' => \$Log::Log4Cli::LEVEL,
        'version|V' => sub { print $self->VERSION . "\n"; die_info undef, 0 },
    )
}

sub configure {
    my $self = shift;
    for my $path (@{$self->{OPTS}->{plugins}}) {
        log_trace { "Loading modiles from $path" };
        map { $self->{plugins}->{$_} = 1 } usesub $path;
    }
}

sub defaults {
    return {
        plugins => [ "NDTools::NDProc::Plugin" ],
    };
}

sub run {
    my $self = bless {}, shift;
    $self->{OPTS} = $self->defaults();
    unless (GetOptions ($self->arg_opts)) {
        $self->usage;
        die_fatal undef, 1;
    }

    my $processor = NDTools::NDProc::Processor->new(@{$self->{OPTS}->{plugins}});
    if ($self->{OPTS}->{'list-modules'}) {
        map { printf "%-10s %-8s %s\n", @{$_} } $processor->list_avail_modules;
        die_info undef, 0;
    }

    my $rules = [];
    if (defined $self->{OPTS}->{module}) {
        push @{$rules}, $processor->get_mod_opts($self->{OPTS}->{module});
        $rules->[-1]->{modname} = $self->{OPTS}->{module};
    } else {
        # here we check rest args, because passthrough used for single-module mode
        # to be sure there is no unsupported opts remain in args
        my $p = Getopt::Long::Parser->new();
        unless ($p->getoptions()) {
            $self->usage;
            die_fatal undef, 1;
        }
    }

    die_fatal "At least one argument expected", 1 unless (@ARGV);

    for my $struct (@ARGV) {
        log_info { "Processing $struct" };
        $struct = s_load($struct, 'JSON');
        $processor->process($struct, $rules);
        s_dump(\*STDOUT, undef, undef, $struct);
    }

    die_info "All done", 0;
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

1; # End of NDTools::NDProc::Module
