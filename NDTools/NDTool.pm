package NDTools::NDTool;

use strict;
use warnings FATAL => 'all';

use Encode::Locale qw(decode_argv);
use NDTools::INC;
use Getopt::Long qw(:config bundling);
use Log::Log4Cli;
use Pod::Usage;

sub VERSION { "n/a" }

sub arg_opts {
    my $self = shift;
    return (
        'help|h' => sub { $self->usage; die_info undef, 0 },
        'pretty!' => \$self->{OPTS}->{pretty},
        'verbose|v:+' => \$Log::Log4Cli::LEVEL,
        'version|V' => sub { print $self->VERSION . "\n"; exit 0; },
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

sub new {
    my $self = bless {}, shift;
    $self->{OPTS} = $self->defaults();
    decode_argv(Encode::FB_CROAK);
    unless (GetOptions ($self->arg_opts)) {
        $self->usage;
        die_fatal "Unsupported opts used", 1;
    }
    $self->configure();
    return $self;
}

sub usage {
    pod2usage(
        -exitval => 'NOEXIT',
        -output => \*STDERR,
        -sections => 'SYNOPSIS|OPTIONS|EXAMPLES',
        -verbose => 99
    );
}

1; # End of NDTools::NDTool
