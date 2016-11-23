package NDTools::NDProc::Processor;

# nested data processor

use strict;
use warnings FATAL => 'all';

use NDTools::INC;
use Log::Log4Cli;
use Module::Find qw(usesub);

sub list_avail_modules {
    my $self = shift;
    return map { [ (split('::', $_))[-1], $_->VERSION, $_->MODINFO ] } sort keys %{$self->{MODS}};
}

sub new {
    my $self = bless {}, shift;
    for my $path (@_) {
        log_trace { "Loading plugins from $path" };
        map { $self->{MODS}->{$_} = 1 } usesub $path;
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
