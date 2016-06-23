package NDTools::Struct;

# structures related subroutines for NDTools

use 5.006;
use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);

use Hash::Merge qw(merge);
use NDTools::HMBehs;
use Storable qw(dclone);
use Struct::Diff qw(diff dsplit);
use Struct::Path qw(spath);

our @EXPORT_OK = qw(
    st_copy
    st_merge
);

# copy whole struct or it's substruct defined by path
sub st_copy($;$) {
    my ($struct, $path) = @_;
    my $out = dclone($struct);

    if ($path) {
        # workaround, until spath will be able to return context for values (ie substrusture)
        spath($out, $path, delete => 1);
        my $diff = diff($struct, $out, noU => 1);
        $out = dsplit($diff);
        $out = $out->{'a'};
    }

    return $out;
}

# merge structures with desired options
sub st_merge($$;@) {
    my ($a, $b, %opts) = @_;
    my %behs = (
        'L_OVERRIDE' => L_OVERRIDE,
        'R_OVERRIDE' => R_OVERRIDE
    );
    my $m = Hash::Merge->new();
    $m->specify_behavior($behs{$opts{'style'}}, $opts{'style'});
    return $m->merge($a, $b);
}

1;
