package NDTools::NDProc;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDTool";

use NDTools::INC;
use Getopt::Long qw(:config bundling pass_through);
use Log::Log4Cli;
use Module::Find qw(findsubmod);
use NDTools::Slurp qw(s_dump s_load);
use Storable qw(dclone);
use Struct::Diff qw(diff dsplit);

sub VERSION { '0.04' }

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
    log_debug { "Dumping structure to $uri" };
    s_dump($uri, undef, undef, $arg);
}

sub dump_blame {
    my ($self, $blame) = @_;
    return unless (defined $self->{OPTS}->{blame});
    log_debug { "Dumping blame to '$self->{OPTS}->{blame}'" };
    s_dump($self->{OPTS}->{blame}, undef, undef, $blame);
}

sub exec {
    my $self = shift;

    $self->init_modules(@{$self->{OPTS}->{modpath}});
    if ($self->{OPTS}->{'list-modules'}) {
        map { printf "%-10s %-8s %s\n", @{$_} } $self->list_modules;
        die_info undef, 0;
    }

    # restore opts common for main program and mods
    push @ARGV, '--help' if ($self->{OPTS}->{help});
    push @ARGV, '--version' if ($self->{OPTS}->{version});

    if (defined $self->{OPTS}->{module}) {
        push @{$self->{rules}}, $self->get_mod_opts($self->{OPTS}->{module});
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
    $self->{rules} = $self->resolve_rules($self->{rules});
    $self->process_args(@ARGV);

    die_info "All done", 0;
}

sub get_mod_opts {
    my ($self, $mod) = @_;
    die_fatal "Unknown module '$mod' specified", 1
        unless (exists $self->{MODS}->{$mod});
    $mod = $self->{MODS}->{$mod}->new(); # will parse rest of args
    return $mod->{OPTS};
}

sub init_modules {
    my $self = shift;
    for my $path (@_) {
        log_trace { "Loooking for modules in $path" };
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

sub list_modules {
    my $self = shift;
    return map { [ $_, $self->{MODS}->{$_}->VERSION, $self->{MODS}->{$_}->MODINFO ] }
        sort keys %{$self->{MODS}};
}

sub load_arg {
    my ($self, $arg) = @_;
    log_debug { "Loading $arg" };
    s_load($arg, undef);
}

*load_source = \&load_arg;

sub process_args {
    my $self = shift;
    for my $arg (@_) {
        my $struct = $self->load_arg($arg);
        my @blame = $self->process_rules(\$struct, $self->{rules});
        $self->dump_arg($arg, $struct);
        $self->dump_blame(\@blame);
    }
}

sub process_rules {
    my ($self, $struct, $rules) = @_;
    my $rcnt = 0; # rules counter
    my @blame;

    for my $rule (@{$rules}) {
        unless ($rule->{enabled}) {
            log_debug { "Rule #$rcnt ($rule->{modname}) is disabled, skip it" };
            next;
        }
        die_fatal "Unknown module '$rule->{modname}' specified (rule #$rcnt)", 1
            unless (exists $self->{MODS}->{$rule->{modname}});

        log_debug { "Processing rule #$rcnt ($rule->{modname})" };
        my $result = dclone(${$struct});
        my $source = exists $rule->{source} ? $self->{sources}->{$rule->{source}} : undef;
        $self->{MODS}->{$rule->{modname}}->new->process($struct, $rule, $source);

        my $changes = { rule_id => 0+$rcnt, %{dsplit(diff($result, ${$struct}, noO => 1, noU => 1))}};
        map { $changes->{$_} = $rule->{$_} if defined $rule->{$_} } qw(comment source);
        push @blame, $changes;

        $rcnt++;
    }

    return @blame;
}

sub resolve_rules {
    my ($self, $rules) = @_;
    my $result;

    log_debug { "Resolving rules" };
    for my $rule (@{$rules}) {
        if (exists $rule->{source} and ref $rule->{source} eq 'ARRAY') {
            for my $src (@{delete $rule->{source}}) {
                my $new = { %{$rule} };
                $new->{source} = $src;
                push @{$result}, $new;
            }
        } else {
            push @{$result}, $rule;
        }
    }

    for my $rule (@{$result}) {
        next unless (exists $rule->{source});
        log_debug { "Loading prerequisite $rule->{source}" };
        $self->{sources}->{$rule->{source}} =
            $self->load_source($rule->{source});
    }

    return $result;
}

1; # End of NDTools::NDProc
