package NDTools::Slurp;

# input/output related subroutines for NDTools

use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);
use open qw(:std :utf8);

use Carp qw(croak);
use File::Basename qw(basename);
use JSON qw();
use Log::Log4Cli;
use YAML::XS qw();

our @EXPORT_OK = qw(
    s_decode
    s_dump
    s_dump_file
    s_encode
    s_fmt_by_uri
    s_load
    s_load_uri
);

our %FORMATS = (
    JSON => {
        allow_nonref => 1,
        canonical => 1,
        pretty => 1,
        relaxed => 1,
    },
);

sub s_decode($$;$) {
    my ($data, $fmt, $opts) = @_;

    if (uc($fmt) eq 'JSON') {
        $data = eval { JSON::from_json($data, {%{$FORMATS{JSON}}, %{$opts || {}}}) };
    } elsif (uc($fmt) eq 'YAML') {
        $data = eval { YAML::XS::Load($data) };
    } else {
        die_fatal "Unable to decode '$fmt' (not supported)";
    }
    die_fatal "Failed to decode '$fmt': " . $@, 4 if $@;

    return $data;
}

sub s_dump(@) {
    my ($uri, $fmt, $opts) = (shift, shift, shift);
    $fmt = s_fmt_by_uri($uri) unless (defined $fmt);
    my $data = join('', map { s_encode($_, $fmt, $opts) } @_);
    if (ref $uri eq 'GLOB') {
        print $uri $data;
    } else {
        eval { s_dump_file($uri, $data) };
        die_fatal $@, 2 if $@;
    }
}

sub s_dump_file($$) {
    my ($file, $data) = @_;
    open(FH, '>', $file) or croak "Failed to open file '$file' ($!)";
    print FH $data;
    close(FH);
}

sub s_encode($$;$) {
    my ($data, $fmt, $opts) = @_;

    if (uc($fmt) eq 'JSON') {
        $data = eval { JSON::to_json($data, {%{$FORMATS{JSON}}, %{$opts || {}}}) };
    } elsif (uc($fmt) eq 'YAML') {
        $data = eval { YAML::XS::Dump($data) };
    } else {
        die_fatal "Unable to encode to '$fmt' (not supported)";
    }
    die_fatal "Failed to encode structure to $fmt: " . $@, 4 if $@;

    return $data;
}

sub s_fmt_by_uri($) {
    my @names = split(/\./, basename(shift));
    if (@names and @names > 1) {
        my $ext = uc(pop @names);
        return 'YAML' if ($ext eq 'YML' or $ext eq 'YAML');
    }
    return 'JSON'; # by default
}

sub s_load($$;@) {
    my ($uri, $fmt, %opts) = @_;
    my $data = eval { s_load_uri($uri) };
    die_fatal $@, 2 if $@;
    $fmt = s_fmt_by_uri($uri) unless (defined $fmt);
    return s_decode($data, $fmt);
}

sub s_load_uri($) {
    my $uri = shift;
    my $data;
    if (ref $uri eq 'GLOB') {
        $data = do { local $/; <$uri> };
    } else {
        open(FH, '<', $uri) or croak "Failed to open file '$uri' ($!)";
        $data = do { local $/; <FH> }; # load whole file
        close(FH);
    }
    return $data;
}

1;
