use strict;
use warnings FATAL => 'all';

use Capture::Tiny qw(capture);
use File::Copy qw(copy);
use Test::File::Contents;
use Test::More tests => 27;

use lib "t";
use NDToolsTest;

chdir t_dir or die "Failed to change test dir";

my (@cmd, $out, $err, $exit);

### essential tests

@cmd = qw/ndproc/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
like($err, qr/ERROR] At least one argument expected/, "Check STDERR for '@cmd'");
is($exit >> 8, 1, "Check exit code for '@cmd'");

@cmd = qw/ndproc -vv -v4 --verbose --verbose 4 -V/;
($out, $err, $exit) = capture { system(@cmd) };
like($out, qr/^\d+\.\d+/, "Check STDOUT for '@cmd'");
like($err, qr/TRACE] /, "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw/ndproc -h --help/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
file_contents_eq_or_diff('help.exp', $err, "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

### bin specific tests

@cmd = qw/ndproc -l --list-modules/;
($out, $err, $exit) = capture { system(@cmd) };
like($out, qr/^\w+\s+[\d\.]+\s+\S/m, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw/ndproc --module NoTeXiStEd/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
like($err, qr/FATAL] Unknown module specified \(NoTeXiStEd\)/, "Check STDERR for '@cmd'");
is($exit >> 8, 1, "Check exit code for '@cmd'");

@cmd = qw/ndproc --rules dump-rules.exp --dump-rules dump-rules.got/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");
files_eq_or_diff('dump-rules.exp', 'dump-rules.got', "Check result for '@cmd'");

copy('../../../test/_data/menu.a.json', 'rules.got') or die "Failed to prepare got file ($!)";
@cmd = qw/ndproc --rules rules.rules.json rules.got/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");
files_eq_or_diff('rules.exp', 'rules.got', "Check result for '@cmd'");

copy('builtin-rules.json', 'builtin-rules.got') or die "Failed to prepare got file ($!)";
@cmd = qw/ndproc --builtin-rules [3]{builtin}{rules} builtin-rules.got/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");
files_eq_or_diff('builtin-rules.exp', 'builtin-rules.got', "Check result for '@cmd'");


