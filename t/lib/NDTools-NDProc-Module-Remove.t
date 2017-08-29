use strict;
use warnings FATAL => 'all';

use Test::More tests => 2;

use lib "t";
use NDToolsTest;
use NDTools::NDProc::Module::Remove;

my ($exp, $got, $mod);

$mod = new_ok('NDTools::NDProc::Module::Remove');

$got = $mod->load_struct('test/_data/menu.a.json');
$mod->process_path($got, '[]{}[](defined)');
$exp = [{File => []},{Edit => [undef,undef]},{View => []}];
is_deeply($got, $exp, "Path with hooks") || diag t_ab_cmp($got, $exp);
