package App::NDTools::NDProc::Module;

# base class for ndproc modules

use strict;
use warnings FATAL => 'all';

use App::NDTools::INC;
use App::NDTools::NDTool;
use Getopt::Long qw(:config bundling pass_through);
use Log::Log4Cli;
use Storable qw(dclone);
use Struct::Path 0.71 qw(spath);
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);

sub MODINFO { "n/a" }
sub VERSION { "n/a" }

sub arg_opts {
    my $self = shift;
    return (
        'blame!' => \$self->{OPTS}->{blame}, # just to set opt in rule
        'help|h' => sub { $self->usage(); exit 0 },
        'path=s@' => \$self->{OPTS}->{path},
        'preserve=s@' => \$self->{OPTS}->{preserve},
        'version|V' => sub { print $self->VERSION . "\n"; exit 0 },
    )
}

sub check_rule {
    my $self = shift;
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

*load_struct = \&App::NDTools::NDTool::load_struct;

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
    my ($self, $data, $opts) = @_;

    $self->check_rule($opts) or die_fatal undef, 1;

    $self->stash_preserved($data, $opts->{preserve}) if ($opts->{preserve});

    map { $self->process_path($data, $_, $opts) } @{$opts->{path}};

    $self->restore_preserved($data) if ($opts->{preserve});
}

sub restore_preserved {
    my ($self, $data) = @_;

    while (@{$self->{_preserved}}) {
        my ($path, $value) = splice @{$self->{_preserved}}, 0, 2;
        log_debug { "Restoring preserved '" . ps_serialize($path) . "'" };
        spath($data, $path, assign => $value, expand => 1);
    }
}

sub stash_preserved {
    my ($self, $data, $paths) = @_;

    for my $path (@{$paths}) {
        log_debug { "Preserving '$path'" };
        my $spath = eval { ps_parse($path) };
        die_fatal "Failed to parse path ($@)", 4 if ($@);
        push @{$self->{_preserved}},
            map { $_ = ref $_ ? dclone($_) : $_ } # immutable now
            spath($data, $spath, deref => 1, paths => 1);
    }
}

sub usage {
    require Pod::Find;
    require Pod::Usage;
    Pod::Usage::pod2usage(
        -exitval => 'NOEXIT',
        -input => Pod::Find::pod_where({-inc => 1}, ref(shift)),
        -output => \*STDERR,
        -sections => 'NAME|DESCRIPTION|OPTIONS',
        -verbose => 99
    );
}

1; # End of App::NDTools::NDProc::Module
