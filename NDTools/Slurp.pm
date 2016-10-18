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
    guess_fmt_by_uri
    s_encode
    s_dump
    s_file_dump
    s_file_load
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

sub s_file_dump($$) {
    my ($file, $data) = @_;
    open(FH, '>', $file) or croak "Failed to open file '$file' $!";
    print FH $data;
    close(FH);
}

sub s_file_load($) {
    my $file = shift;
    open(FH, '<', $file) or croak "Failed to open file '$file' $!";
    my $data = do { local $/; <FH> }; # load whole file
    close(FH);
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
    if (ref $uri eq 'GLOB') {
        print $uri $data;
    } else {
        eval { s_file_dump($uri, $data) };
        die_fatal "Failed to dump structure: " . $@, 2 if $@;
    }
}

sub st_load($$;@) {
    my ($uri, $fmt, %opts) = @_;
    my $data = eval { s_file_load($uri) };
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
