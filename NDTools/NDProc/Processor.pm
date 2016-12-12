package NDTools::NDProc::Processor;

# nested data processor

use strict;
use warnings FATAL => 'all';

use NDTools::INC;
use Log::Log4Cli;
use Module::Find qw(findsubmod);
use Storable qw(dclone);
use Struct::Diff qw(diff dsplit);

sub get_mod_opts {
    my ($self, $mod) = @_;
    die_fatal "Unknown module '$mod' specified", 1
        unless (exists $self->{MODS}->{$mod});
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
    my $rcnt = 0; # rules counter
    my @blame;
    for my $rule (@{$rules}) {
        unless ($rule->{enabled}) {
            log_debug { $rule->{modname} . "is disabled, skip it "};
            next;
        }
        die_fatal "Unknown module '$rule->{modname}' specified (rule #$rcnt)", 1
            unless (exists $self->{MODS}->{$rule->{modname}});

        log_debug { "Processing rule #$rcnt ($rule->{modname})" };
        my $module = $self->{MODS}->{$rule->{modname}}->new();
        my $result = dclone($struct);
        $module->process($struct, $rule);
        push @blame, {
            rule_number => $rcnt,
            comment => $rule->{comment},
            %{dsplit(diff($result, $struct, noO => 1, noU => 1))},
        };
        $struct = $result;
    }
    return @blame;
}

1; # End of NDTools::NDProc::Processor
