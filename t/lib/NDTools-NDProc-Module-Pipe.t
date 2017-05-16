use strict;
use warnings FATAL => 'all';

use Test::More tests => 1;

use lib "t";
use NDToolsTest;
use NDTools::NDProc::Module::Pipe;

#chdir t_dir or die "Failed to change test dir";

my $mod = new_ok('NDTools::NDProc::Module::Pipe');

