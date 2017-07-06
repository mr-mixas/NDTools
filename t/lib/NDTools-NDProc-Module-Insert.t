use strict;
use warnings FATAL => 'all';

use Test::More tests => 2;

use lib "t";
use NDToolsTest;
use NDTools::NDProc::Module::Insert;

my ($exp, $got, $mod);

$mod = new_ok('NDTools::NDProc::Module::Insert');

$got = [0, 1, 2, 3];
$mod->process($got, { path => ['[]'], preserve => ['[1,0]'], value => 'test' });
$exp = [0,1,'test','test'];
is_deeply($got, $exp, "Path with hooks") || diag t_ab_cmp($got, $exp);

