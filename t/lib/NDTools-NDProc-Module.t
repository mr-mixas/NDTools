use strict;
use warnings FATAL => 'all';

use Capture::Tiny qw(capture);
use Test::File::Contents;
use Test::More;

use lib "t";
use NDToolsTest;

use NDTools::NDProc;

#chdir t_dir or die "Failed to change test dir";

my $ndproc = NDTools::NDProc->new() or die "Failed to instabntiate 'NDTools::NDProc'";

for my $mod (sort keys %{$ndproc->{MODS}}) {
    $ndproc->{OPTS}->{module} = $mod;
    ok(eval { $ndproc->init_module($mod) }, "Init mod $mod") or next;

    my ($out, $err, $val) = capture { $ndproc->{MODS}->{$mod}->new->usage() };
    is($out, '', "$mod: Usage goes to STDERR (STDOUT must remain empty)");
    like($err, qr/^Name:/, "$mod: Usage must starts with 'Name' field");
    like($err, qr/^Options:/m, "$mod: Usage must contain 'Options' field");

    like($ndproc->VERSION, qr/\d+\.\d+.*/, "version must be a number");

    can_ok($ndproc->{MODS}->{$mod}, qw(
        MODINFO
        VERSION
        arg_opts
        configure
        defaults
        get_opts
        load_uri
        usage
        parse_args
        process
        restore_preserved
        stash_preserved
        usage
    ));
}

done_testing(keys(%{$ndproc->{MODS}}) * 6);
