use strict;
use warnings FATAL => 'all';

use Test::More tests => 6;

use lib "t";
use NDToolsTest;

use_ok('NDTools::NDTool');

my ($tool, $got, $exp, $tmp);

$tool = new_ok('NDTools::NDTool') || die "Failed to init module";

can_ok($tool, qw(VERSION arg_opts configure defaults usage));

$tmp = eval { $tool->load_uri('file-does-not-exists') };
like($@, qr/^Failed to open file/, "Must fail when file doesn't exists");

$tmp = $tool->load_uri('test/_data/menu.a.json');

($got) = $tool->grep([$tmp], [[],{regs => [qr/^.i/]},[],{keys => ['id']}]);
$exp = [
    {
        File => [
            {id => 'file_new'},
            {id => 'file_open'},
            {id => 'file_save'}
        ]
    },
    {
        View => [
            {id => 'view_encoding'},
            {id => 'view_wrapping'}
        ]
    }
];
is_deeply($got, $exp, "Grep match") || diag t_ab_cmp($got, $exp);

$got = $tool->grep([$tmp], [[],{regs => [qr/^NotExists/]},[],{keys => ['id']}]);
is_deeply($got, 0, "Grep doesn't match") || diag t_ab_cmp($got, $exp);

