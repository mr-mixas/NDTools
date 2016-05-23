package NDTools::Struct;

# structures related subroutines for NDTools

use 5.006;
use strict;
use warnings FATAL => 'all';
use parent 'Exporter';

use Hash::Merge qw(merge);
use Storable qw(dclone);
use Struct::Diff qw(diff dsplit);
use Struct::Path qw(spath);

our @EXPORT_OK = qw(
    cp_struct
);

# copy whole struct or it's substruct defined by path
sub cp_struct($;$) {
    my ($struct, $path) = @_;

    my $out = dclone($struct);

    return $out unless ($path);

    # workaround, until spath will be able to return context for values (ie substrusture)
    spath($out, $path, delete => 1);
    my $diff = diff($struct, $out, noU => 1);
    $out = dsplit($diff);
    $out = $out->{'a'};

    return $out;
}

1;
