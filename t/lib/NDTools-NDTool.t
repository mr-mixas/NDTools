use strict;
use warnings FATAL => 'all';

use Test::File::Contents;
use Test::More tests => 4;

use lib "t";
use NDToolsTest;

#chdir t_dir or die "Failed to change test dir";

use_ok('NDTools::NDDiff');

my ($lib, $got, $exp, $tmp);

$lib = new_ok('NDTools::NDTool') || die "Failed to init module";
$tmp = { a => 1, aa => 2, b => 3 };

$got = [ $lib->grep([$tmp], [{regs => [qr/^a/]}]) ];
$exp = [{a => 1,aa => 2}];
is_deeply($got, $exp, "Diff same texts") || diag t_ab_cmp($got, $exp);

$got = [ $lib->grep([$tmp], [{regs => [qr/^c/]}]) ];
$exp = [];
is_deeply($got, $exp, "Diff same texts") || diag t_ab_cmp($got, $exp);

