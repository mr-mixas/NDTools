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

@cmd = qw/ndquery <\/dev\/null/;
($out, $err, $exit) = capture { system("@cmd") };
is($out, '', "Check STDOUT for '@cmd'");
like($err, qr/FATAL] Failed to decode/, "Check STDERR for '@cmd'");
is($exit >> 8, 4, "Check exit code for '@cmd'");

@cmd = qw/ndquery -vv -v4 --verbose --verbose 4 -V/;
($out, $err, $exit) = capture { system(@cmd) };
like($out, qr/^\d+\.\d+/, "Check STDOUT for '@cmd'");
like($err, qr//, "Check STDERR for '@cmd'"); # FIXME
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw/ndquery -h --help/;
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
file_contents_eq_or_diff('help.exp', $err, "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

### bin specific tests

@cmd = qw(ndquery ../../../test/alpha.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('../../../test/alpha.json', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery ../../../test/_data/bool.yaml);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff(
    '../../../test/_data/bool.yaml', $out,
    "YAML bool values must be correctly converted"
);
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --list ../../../test/alpha.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('list.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --list --depth 1 ../../../test/alpha.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('list-depth.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --list --path {files} ../../../test/alpha.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('list-path.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --list --colors ../../../test/_data/deep-down-lorem.a.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('list-colors.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --list --values --vals ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('list-values.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --list --values --vals --depth 3 ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('list-values-depth.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --md5 ../../../test/_data/menu.a.json ../../../test/_data/menu.b.json ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('md5.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --md5 --path [0]{File}[0]{label} ../../../test/_data/menu.a.json ../../../test/_data/menu.b.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('md5-path.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --path {files}{"/etc/hosts"} ../../../test/alpha.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('path-00.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --path [] ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('path-01.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = ('ndquery', '--path', '[1]{Edit}[]{id}(eq "edit_paste")(<<)', '../../../test/_data/menu.a.json');
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('path-02.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = ('ndquery', '--path', '[1]{Edit}[](not defined)', '../../../test/_data/menu.a.json');
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('path-03.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = ('ndquery', '--path', '{"текст"}', '../../../test/_data/text-utf8.a.json');
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('path-04.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --raw-output --path [0]{File}[1] ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('raw-output-object.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --raw-output --path [0]{File}[1]{label} ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('raw-output-string.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --strict --path [0]{NoTeXiStS} ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
like($err, qr/FATAL] Failed to lookup/, "Check STDERR for '@cmd'");
is($exit >> 8, 8, "Check exit code for '@cmd'");

@cmd = qw(ndquery --nostrict --path [0]{NoTeXiStS} ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
is($out, '', "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --grep []{/^.i/}[1]{id} ../../../test/_data/menu.a.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('grep-00.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = ('ndquery', '--grep', '[]{}[](not defined)', '../../../test/_data/menu.a.json');
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('grep-01.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

@cmd = qw(ndquery --grep {files} --grep {fqdn} ../../../test/alpha.json);
($out, $err, $exit) = capture { system(@cmd) };
file_contents_eq_or_diff('grep-02.exp', $out, "Check STDOUT for '@cmd'");
is($err, '', "Check STDERR for '@cmd'");
is($exit >> 8, 0, "Check exit code for '@cmd'");

done_testing();
