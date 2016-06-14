package NDTools::Format;

# format related subroutines for NDTools

use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);

use JSON qw();
use Log::Log4Cli;

our @EXPORT_OK = qw(
    dec_json
    enc_json
);

sub dec_json($;@) {
    my ($text, %opts) = @_;
    my $struct = eval { JSON::from_json($text, {relaxed => 1, %opts}) };
    return $struct unless ($@);
    log_error { $@ };
    return undef;
}

sub enc_json($;@) {
    my ($struct, %opts) = @_;
    my $text = eval { JSON::to_json($struct, {pretty => 1, canonical => 1, %opts}) };
    return $text unless ($@);
    log_error { $@ };
    return undef;
}

1;
