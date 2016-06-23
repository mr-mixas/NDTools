package NDTools::Slurp;

# input/output related subroutines for NDTools

use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);

use File::Basename qw(basename);
use File::Slurp qw(read_file write_file);
use JSON qw();
use Log::Log4Cli;

our @EXPORT_OK = qw(
    guess_fmt_by_uri
    st_dump
    st_load
);

our %FORMATS = (
    JSON => {
        allow_nonref => 0,
        canonical => 1,
        pretty => 1,
        relaxed => 1,
    },
);

sub guess_fmt_by_uri($) {
    my @names = split(".", basename(shift));
    if (@names and @names > 1) {
        my $ext = uc(pop @names);
        return 'YAML' if ($ext eq 'YML' or $ext eq 'YAML');
    }
    return 'JSON'; # by default
}

sub st_dump($$$;@) {
    my ($uri, $data, $fmt, %opts) = @_;
    $fmt = guess_fmt_by_uri($uri) unless (defined $fmt);
    if ($fmt eq 'JSON') {
        $data = eval { JSON::to_json($data, {%{$FORMATS{JSON}}, %opts}) };
    } else {
        die_fatal "$fmt not supported yet", 4;
    }
    die_fatal $@, 4 if $@; # convert related
    eval { write_file($uri, $data) };
    die_fatal $@, 2 if $@;
}

sub st_load($$;@) {
    my ($uri, $fmt, %opts) = @_;
    my $data = eval { read_file($uri) };
    die_fatal $@, 2 if $@;
    $fmt = guess_fmt_by_uri($uri) unless (defined $fmt);
    if ($fmt eq 'JSON') {
        $data = eval { JSON::from_json($data, {%{$FORMATS{JSON}}, %opts}) };
    } else {
         die_fatal "$fmt not supported yet", 4;
    }
    die_fatal $@, 4 if $@; # convert related
    return $data;
}

1;
