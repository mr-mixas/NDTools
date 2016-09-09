package NDTools::Slurp;

# input/output related subroutines for NDTools

use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);
use open qw(:std :utf8);

use File::Basename qw(basename);
use File::Slurp qw(read_file write_file);
use JSON qw();
use Log::Log4Cli;
use YAML::XS qw();

our @EXPORT_OK = qw(
    guess_fmt_by_uri
    s_encode
    s_dump
    st_dump
    st_load
);

our %FORMATS = (
    JSON => {
        allow_nonref => 1,
        canonical => 1,
        pretty => 1,
        relaxed => 1,
    },
);

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

sub guess_fmt_by_uri($) {
    my @names = split(/\./, basename(shift));
    if (@names and @names > 1) {
        my $ext = uc(pop @names);
        return 'YAML' if ($ext eq 'YML' or $ext eq 'YAML');
    }
    return 'JSON'; # by default
}

sub s_dump(@) {
    my ($uri, $fmt, $opts) = (shift, shift, shift);
    $fmt = guess_fmt_by_uri($uri) unless (defined $fmt);
    my $data = join($/, map { s_encode($_, $fmt, $opts) } @_);
    eval { write_file($uri, $data) };
    die_fatal "Failed to dump structure: " . $@, 2 if $@;
}

sub st_dump($$$;@) {
    my ($uri, $data, $fmt, %opts) = @_;
    $fmt = guess_fmt_by_uri($uri) unless (defined $fmt);
    if (uc($fmt) eq 'JSON') {
        $data = eval { JSON::to_json($data, {%{$FORMATS{JSON}}, %opts}) };
    } elsif (uc($fmt) eq 'YAML') {
        $data = eval { YAML::XS::Dump($data) };
    } else {
        die_fatal "$fmt not supported yet", 4;
    }
    die_fatal "Failed to serialize structure: " . $@, 4 if $@; # convert related
    eval { write_file($uri, $data) };
    die_fatal "Failed to dump structure: " . $@, 2 if $@;
}

sub st_load($$;@) {
    my ($uri, $fmt, %opts) = @_;
    my $data = eval { read_file($uri) };
    die_fatal "Failed to load file: " . $@, 2 if $@;
    $fmt = guess_fmt_by_uri($uri) unless (defined $fmt);
    if (uc($fmt) eq 'JSON') {
        $data = eval { JSON::from_json($data, {%{$FORMATS{JSON}}, %opts}) };
    } elsif (uc($fmt) eq 'YAML') {
        $data = eval { YAML::XS::Load($data) };
    } else {
         die_fatal "$fmt not supported yet", 4;
    }
    die_fatal "Failed to parse $fmt: " . $@, 4 if $@; # convert related
    return $data;
}

1;
