use strict;
use warnings FATAL => 'all';

use Capture::Tiny qw(capture);
use File::Copy qw(copy);
use Test::File::Contents;
use Test::More tests => 17;

use lib "t";
use NDToolsTest;

chdir t_dir or die "Failed to change test dir";

my (@cmd, $out, $err, $exit);

### essential tests

@cmd = qw/ndpatch/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
like($err, qr/FATAL] One or two arguments expected/, "Check STDERR for '@cmd'");
is($exit >> 8, 1, "Check exit code for '@cmd'");

@cmd = qw/ndpatch -vv -v4 --verbose --verbose 4 -V/;
($out, $err, $exit) = capture { system(@cmd) };
like($out, qr/^\d+\.\d+/, "Check STDOUT for '@cmd'");
like($err, qr//, "Check STDERR for '@cmd'"); # FIXME
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw/ndpatch -h --help/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
file_contents_eq_or_diff('help.exp', $err, "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

### bin specific tests

copy('../../../test/_data/menu.a.json', 'patch.got') or
    die "Failed to prepare got file ($!)";
@cmd = qw/ndpatch patch.got patch.json/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");
files_eq_or_diff(
    '../../../test/_data/menu.b.json',
    'patch.got',
    "Check result for '@cmd'"
);

copy('../../../test/_data/menu.b.json', 'STDIN.got') or
    die "Failed to prepare got file ($!)";
@cmd = qw/ndpatch STDIN.got STDIN.json/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");
files_eq_or_diff(
    '../../../test/_data/menu.a.json',
    'STDIN.got',
    "Check result for '@cmd'"
);

