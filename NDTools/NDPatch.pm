package NDTools::NDPatch;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDTool";

use NDTools::INC;
use NDTools::Slurp qw(s_dump);
use Log::Log4Cli;
use Struct::Diff qw();

sub VERSION { '0.03' };

sub arg_opts {
    my $self = shift;
    return (
        $self->SUPER::arg_opts(),
    );
}

sub defaults {
    my $self = shift;
    return {
        %{$self->SUPER::defaults()},
    };
}

sub dump {
    my ($self, $uri, $struct) = @_;
    log_debug { "Restoring structure to '$uri'" };
    s_dump($uri, undef, {pretty => $self->{OPTS}->{pretty}}, $struct);
}

sub exec {
    my $self = shift;
    die_fatal "One or two arguments expected", 1
        if (@ARGV < 1 or @ARGV > 2);

    my $uri = shift @ARGV;
    my $struct = $self->load_struct($uri);
    my $patch = $self->load_patch(@ARGV ? shift @ARGV : \*STDIN);

    $self->patch($struct, $patch);
    $self->dump($uri, $struct);

    die_info "All done", 0;
}

sub load_patch {
    shift->load_uri(@_);
}

*load_struct = \&load_patch;

sub patch {
    my ($self, $struct, $patch) = @_;
    eval { Struct::Diff::patch($struct, $patch) };
    die_fatal "Failed to patch structure ($@)", 8 if ($@);
}

1; # End of NDTools::NDPatch
