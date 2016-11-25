package NDTools::NDProc::Processor;

# nested data processor

use strict;
use warnings FATAL => 'all';

use NDTools::INC;
use Log::Log4Cli;
use Module::Find qw(findsubmod);

sub get_mod_opts {
    my ($self, $mod) = @_;
    $mod = $self->{MODS}->{$mod}->new(); # will parse rest of args
    return $mod->{OPTS};
}

sub list_avail_modules {
    my $self = shift;
    return map { [ $_, $self->{MODS}->{$_}->VERSION, $self->{MODS}->{$_}->MODINFO ] }
        sort keys %{$self->{MODS}};
}

sub new {
    my $self = bless {}, shift;
    for my $path (@_) {
        log_trace { "Loading plugins from $path" };
        for my $m (findsubmod $path) {
            $self->{MODS}->{(split('::', $m))[-1]} = $m;
        }
    }
    for my $m (keys %{$self->{MODS}}) {
        log_trace { "Initializing module $m ($self->{MODS}->{$m})" };
        eval "require $self->{MODS}->{$m}";
        die_fatal "Failed to initialize module '$m' ($@)", 1 if ($@);
    }
    return $self;
}

sub process {
    my ($self, $struct, $rules) = @_;
    for my $r (@{$rules}) {
        log_debug { "Processing rule $r->{modname}" };
    }
}

1; # End of NDTools::NDProc::Processor
