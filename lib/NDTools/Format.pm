package NDTools::Format;

# format related subroutines for NDTools

use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);

use JSON qw();
use Log::Log4Cli;

our %EXPORT_TAGS = (
    'JSON' => [qw(
        dec_json
        enc_json
    )],
);
$EXPORT_TAGS{all} = [ map { @{$_} } values %EXPORT_TAGS ];
our @EXPORT_OK = (
    @{$EXPORT_TAGS{all}}
);

our %FORMATS = (
    JSON => {
        allow_nonref => 0,
        canonical => 1,
        pretty => 1,
        relaxed => 1,
    },
);

sub dec_json($;@) {
    my ($text, %opts) = @_;
    my $struct = eval { JSON::from_json($text, {%{$FORMATS{JSON}}, %opts}) };
    return $struct unless ($@);
    log_error { $@ };
    return undef;
}

sub enc_json($;@) {
    my ($struct, %opts) = @_;
    my $text = eval { JSON::to_json($struct, {%{$FORMATS{JSON}}, %opts}) };
    return $text unless ($@);
    log_error { $@ };
    return undef;
}

1;
