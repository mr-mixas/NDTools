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
        'list-modules|l' => \$self->{OPTS}->{'list-modules'},
        'module|m=s' => \$self->{OPTS}->{module},
        'rules=s' => sub { push @{$self->{rules}}, @{s_load($_[1], undef)} },
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

sub exec {
    my $self = shift;

    my $processor = NDTools::NDProc::Processor->new(@{$self->{OPTS}->{modpath}});
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
        log_info { "Loading $struct" };
        $struct = s_load($struct, 'JSON');
        my @blame = $processor->process($struct, $rules);
        s_dump(\*STDOUT, undef, undef, $struct);
        s_dump($self->{OPTS}->{blame}, undef, undef, \@blame)
            if (defined $self->{OPTS}->{blame});
    }

    die_info "All done", 0;
}

1; # End of NDTools::NDProc
