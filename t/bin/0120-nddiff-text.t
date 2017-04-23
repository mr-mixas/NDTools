use strict;
use warnings FATAL => 'all';

use Test::File::Contents;
use Test::More tests => 4;

use lib "t";
use NDToolsTest;

chdir t_dir or die "Failed to change test dir";

use_ok('NDTools::NDDiff');

my ($bin, $got, $exp);

$bin = new_ok('NDTools::NDDiff') || die "Failed to init module";
$bin->load('text-123.json', 'text-123.json'); # FIXME: make load return $self
$got = $bin->diff();
$exp = {};
is_deeply($got, $exp, "Diff same texts") || diag t_ab_cmp($got, $exp);

$bin = NDTools::NDDiff->new();
$bin->load('text-123.json', 'text-456.json'); # FIXME: make load return $self
$got = $bin->diff();
$exp = {T => [{R => ['1','2','3']},{A => ['4','5','6']}]};
is_deeply($got, $exp, "Diff totally different texts") || diag t_ab_cmp($got, $exp);

