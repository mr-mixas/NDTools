use strict;
use warnings FATAL => 'all';

use File::Copy qw(copy);
use Test::File::Contents;
use Test::More tests => 1;

use NDTools::INC;
use NDTools::Test;

chdir t_dir or die "Failed to change test dir";

my $test;
my @cmd = qw/ndproc --module Insert/;

$test = "file_fmt_raw";
run_ok(
    name => $test,
    pre => sub { copy("$test.a.json", "$test.got") },
    cmd => [ @cmd, qw(--path {new}{path} --file-fmt RAW --file), "$test.b.json", "$test.got" ],
    test => sub { files_eq_or_diff("$test.exp", "$test.got", $test) },
);

