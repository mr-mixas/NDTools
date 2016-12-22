package NDTools::NDProc;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDTool";

use NDTools::INC;
use Getopt::Long qw(:config bundling pass_through);
use Log::Log4Cli;
use NDTools::NDProc::Processor;
use NDTools::Slurp qw(s_dump s_load);

sub VERSION { '0.03' }

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
        'dump-blame=s' => \$self->{OPTS}->{blame},
        'dump-rules=s' => \$self->{OPTS}->{'dump-rules'},
        'help|h' => \$self->{OPTS}->{help}, # redefine parent's
        'list-modules|l' => \$self->{OPTS}->{'list-modules'},
        'module|m=s' => \$self->{OPTS}->{module},
        'rules=s' => sub { push @{$self->{rules}}, @{s_load($_[1], undef)} },
        'version|V' => \$self->{OPTS}->{version}, # redefine parent's
    )
}

sub configure {
    my $self = shift;
}

sub defaults {
    return {
        modpath => [ "NDTools::NDProc::Module" ],
    };
}

sub dump_arg {
    my ($self, $uri, $arg) = @_;
    log_info { "Dumping '$arg'" };
    s_dump($uri, undef, undef, $arg);
}

sub exec {
    my $self = shift;

    my $processor = NDTools::NDProc::Processor->new(@{$self->{OPTS}->{modpath}});
    if ($self->{OPTS}->{'list-modules'}) {
        map { printf "%-10s %-8s %s\n", @{$_} } $processor->list_avail_modules;
        die_info undef, 0;
    }

    # restore opts common for main program and mods
    push @ARGV, '--help' if ($self->{OPTS}->{help});
    push @ARGV, '--version' if ($self->{OPTS}->{version});

    if (defined $self->{OPTS}->{module}) {
        push @{$self->{rules}}, $processor->get_mod_opts($self->{OPTS}->{module});
        $self->{rules}->[-1]->{modname} = $self->{OPTS}->{module};
    } else {
        # here we check rest args (passthrough used for single-module mode)
        # to be sure there is no unsupported opts remain in args
        my @rest_opts = (
            'help|h' => sub { $self->usage; die_info undef, 0 },
            'version|V' => sub { print $self->VERSION . "\n"; die_info undef, 0; },
        );
        my $p = Getopt::Long::Parser->new();
        unless ($p->getoptions(@rest_opts)) {
            $self->usage;
            die_fatal "Unsupported opts passed", 1;
        }
    }

    if ($self->{OPTS}->{'dump-rules'}) {
        s_dump($self->{OPTS}->{'dump-rules'}, undef, undef, $self->{rules});
        die_info "All done", 0;
    }

    die_fatal "At least one argument expected", 1 unless (@ARGV);

    for my $arg (@ARGV) {
        my $struct = $self->load_arg($arg);
        my @blame = $processor->process($struct, $self->{rules});
        s_dump($self->{OPTS}->{blame}, undef, undef, \@blame)
            if (defined $self->{OPTS}->{blame});
        $self->dump_arg(\*STDOUT, $struct);
    }

    die_info "All done", 0;
}

sub load_arg {
    my ($self, $arg) = @_;
    log_info { "Loading '$arg'" };
    s_load($arg, undef);
}

1; # End of NDTools::NDProc
