package NDToolsTest;

use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);

use Data::Dumper qw();

our @EXPORT = qw(
    t_ab_cmp
    t_dir
    t_dump
);

sub t_ab_cmp {
    return "GOT: " . t_dump(shift) . ";\nEXP: " . t_dump(shift) . ";";
}

# called within t-file returns it's personal test dir (ie /path/to/00-test.t.d for /path/to/00-test.t)
sub t_dir {
    my $tf = shift || (caller)[1];
    substr($tf, 0, length($tf) - 2) . ".d";
}

# return neat one-line string of perl serialized structure
sub t_dump {
    return Data::Dumper->new([shift])->Terse(1)->Sortkeys(1)->Quotekeys(0)->Indent(0)->Deepcopy(1)->Dump();
}

1;
