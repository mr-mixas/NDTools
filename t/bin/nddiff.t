use strict;
use warnings FATAL => 'all';

use Capture::Tiny qw(capture);
use Test::File::Contents;
use Test::More;

use lib "t";
use NDToolsTest;

chdir t_dir or die "Failed to change test dir";

my (@cmd, $out, $err, $exit);

### essential tests

@cmd = qw/nddiff/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
like($err, qr/ERROR] Two arguments expected for diff/, "Check STDERR for '@cmd'");
is($exit >> 8, 1, "Check exit code for '@cmd'");

@cmd = qw/nddiff -vv -v4 --verbose --verbose 4 -V/;
($out, $err, $exit) = capture { system(@cmd) };
like($out, qr/^\d+\.\d+/, "Check STDOUT for '@cmd'");
like($err, qr//, "Check STDERR for '@cmd'"); # FIXME
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw/nddiff -h --help/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
file_contents_eq_or_diff('help.exp', $err, "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

### bin specific tests

@cmd = qw(nddiff --brief ../../../test/_data/menu.a.json ../../../test/_data/menu.b.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('brief.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff --brief --colors ../../../test/_data/bool.a.json ../../../test/_data/bool.b.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('brief-colors.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

# [5] here is added item, that's why empty STDOUT. But exit code must be 8 - diff exists after all
@cmd = qw(nddiff --brief --path [1]{Edit}[5] ../../../test/_data/menu.a.json ../../../test/_data/menu.b.json);
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
like($err, qr/ALERT] Opt --path is deprecated and will be removed/, "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff --rules ../../../test/alpha.json ../../../test/beta.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('rules.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff --grep {list}[1] ../../../test/_data/bool.a.json ../../../test/_data/bool.b.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('grep.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff --grep {fqdn} --grep {mtime} ../../../test/alpha.json ../../../test/beta.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('grep2.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff --colors ../../../test/alpha.json ../../../test/beta.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('term-colors.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff --full-headers ../../../test/alpha.json ../../../test/beta.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('term-full_headers.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff --nopretty ../../../test/_data/menu.a.json ../../../test/_data/menu.b.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('term-nopretty.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff --nopretty ../../../test/_data/menu.a.json ../../../test/_data/menu.b.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('term-nopretty.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff ../../../test/_data/menu.a.json ../../../test/_data/menu.b.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('term-_array-00.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff ../../../test/_data/menu.b.json ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('term-_array-01.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(nddiff ../../../test/_data/struct-subkey-AR.a.json ../../../test/_data/struct-subkey-AR.b.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('term-struct-subkey-AR.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

done_testing();
