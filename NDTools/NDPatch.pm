package NDTools::NDPatch;

use strict;
use warnings FATAL => 'all';

use Getopt::Long qw(:config bundling);
use NDTools::INC;
use NDTools::Slurp qw(s_dump s_load);
use Log::Log4Cli;
use Struct::Diff;
use Pod::Usage;

our $VERSION = '0.02';

sub arg_opts {
    my $self = shift;
    return (
        'help|h' => sub {
            pod2usage(-exitval => 1, -output => \*STDERR,
            -sections => 'SYNOPSIS|OPTIONS|EXAMPLES', -verbose => 99)
        },
        'pretty!' => \$self->{OPTS}->{pretty},
        'verbose|v:+' => \$Log::Log4Cli::LEVEL,
        'version|V' => sub { print "$VERSION\n"; exit 0; },
    );
}

sub configure {
    my $self = shift;
}

sub defaults {
    return {
        'pretty' => 1,
    };
}

sub dump {
    my ($self, $uri, $struct) = @_;
    log_debug { "Restoring structure to '$uri'" };
    s_dump($uri, undef, {pretty => $self->{OPTS}->{pretty}}, $struct);
}

sub load_patch {
    my ($self, $uri) = @_;
    log_debug { "Loading patch from " . (ref $uri ? "STDIN" : "'$uri'")};
    s_load($uri, undef);
}

sub load_struct {
    my ($self, $uri) = @_;
    log_debug { "Loading structure from $uri" };
    s_load($uri, undef);
}

sub patch {
    my ($self, $struct, $patch) = @_;
    eval { Struct::Diff::patch($struct, $patch) };
    die_fatal "Failed to patch structure ($@)", 8 if ($@);
}

sub run {
    my $self = bless {}, shift;
    $self->{OPTS} = $self->defaults();
    unless (GetOptions ($self->arg_opts)) {
        $self->usage;
        die_fatal undef, 1;
    }

    die_fatal "One or two arguments expected", 1
        if (@ARGV < 1 or @ARGV > 2);

    $self->configure();

    my $uri = shift @ARGV;
    my $struct = $self->load_struct($uri);
    my $patch = $self->load_patch(@ARGV ? shift @ARGV : \*STDIN);

    $self->patch($struct, $patch);
    $self->dump($uri, $struct);

    die_info "All done", 0;
}

sub usage {
    pod2usage(
        -exitval => 'NOEXIT',
        -output => \*STDERR,
        -sections => 'SYNOPSIS|OPTIONS|EXAMPLES',
        -verbose => 99
    );
}

1; # End of NDTools::NDPatch
