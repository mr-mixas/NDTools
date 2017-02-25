package NDTools::Path;

# path related wrappers for NDTools

use 5.006;
use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);

use NDTools::INC;
use Log::Log4Cli;
use Struct::Path qw();
use Struct::Path::PerlStyle qw(ps_parse ps_serialize);

our @EXPORT_OK = qw(
    path
    path2str
    spath
    str2path
);

sub path {
    my ($data, $str, %opts) = @_;
    my @paths = eval { spath($data, str2path($str), %opts) };
    die_fatal "$@", 4 if ($@);
    return @paths;
}

sub path2str {
    my $str = eval { ps_serialize(shift) };
    die_fatal "$@", 4 if ($@);
    return $str;
}

sub spath {
    my ($data, $spath, %opts) = @_;
    my @paths = eval { Struct::Path::spath($data, $spath, %opts) };
    die_fatal "$@", 4 if ($@);
    return @paths;
}

sub str2path {
    my $path = eval { ps_parse(shift) };
    die_fatal "$@" if ($@);
    return $path;
}

1; # End of NDTools::Path
