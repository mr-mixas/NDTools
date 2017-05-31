use strict;
use warnings FATAL => 'all';

use Capture::Tiny qw(capture);
use File::Copy qw(copy);
use Test::File::Contents;
use Test::More tests => 27;

use lib "t";
use NDToolsTest;

chdir t_dir or die "Failed to change test dir";

my (@args, $out, $err, $exit);

### essential tests

@args = qw/ndproc/;
($out, $err, $exit) = capture { system(@args) };
is($out, '', "Check STDOUT for '@args'");
like($err, qr/FATAL] At least one argument expected/, "Check STDERR for '@args'");
is($exit >> 8, 1, "Check exit code for '@args'");

@args = qw/ndproc -vv -v4 --verbose --verbose 4 -V/;
($out, $err, $exit) = capture { system(@args) };
like($out, qr/^\d+\.\d+/, "Check STDOUT for '@args'");
like($err, qr/TRACE] /, "Check STDERR for '@args'");
is($exit >> 8, 0, "Check exit code for '@args'");

@args = qw/ndproc -h --help/;
($out, $err, $exit) = capture { system(@args) };
is($out, '', "Check STDOUT for '@args'");
file_contents_eq_or_diff('help.exp', $err, "Check STDERR for '@args'");
is($exit >> 8, 0, "Check exit code for '@args'");

### bin specific tests

@args = qw/ndproc -l --list-modules/;
($out, $err, $exit) = capture { system(@args) };
like($out, qr/^\w+\s+[\d\.]+\s+\S/m, "Check STDOUT for '@args'");
is($err, '', "Check STDERR for '@args'");
is($exit >> 8, 0, "Check exit code for '@args'");

@args = qw/ndproc --module NoTeXiStEd/;
($out, $err, $exit) = capture { system(@args) };
is($out, '', "Check STDOUT for '@args'");
like($err, qr/FATAL] Unknown module specified \(NoTeXiStEd\)/, "Check STDERR for '@args'");
is($exit >> 8, 1, "Check exit code for '@args'");

@args = qw/ndproc --rules dump-rules.exp --dump-rules dump-rules.got/;
($out, $err, $exit) = capture { system(@args) };
is($out, '', "Check STDOUT for '@args'");
is($err, '', "Check STDERR for '@args'");
is($exit >> 8, 0, "Check exit code for '@args'");
files_eq_or_diff('dump-rules.exp', 'dump-rules.got', "Check result for '@args'");

copy('../../../test/_data/menu.a.json', 'rules.got') or die "Failed to prepare got file ($!)";
@args = qw/ndproc --rules rules.rules.json rules.got/;
($out, $err, $exit) = capture { system(@args) };
is($out, '', "Check STDOUT for '@args'");
is($err, '', "Check STDERR for '@args'");
is($exit >> 8, 0, "Check exit code for '@args'");
files_eq_or_diff('rules.exp', 'rules.got', "Check result for '@args'");

copy('builtin-rules.json', 'builtin-rules.got') or die "Failed to prepare got file ($!)";
@args = qw/ndproc --builtin-rules [3]{builtin}{rules} builtin-rules.got/;
($out, $err, $exit) = capture { system(@args) };
is($out, '', "Check STDOUT for '@args'");
is($err, '', "Check STDERR for '@args'");
is($exit >> 8, 0, "Check exit code for '@args'");
files_eq_or_diff('builtin-rules.exp', 'builtin-rules.got', "Check result for '@args'");


