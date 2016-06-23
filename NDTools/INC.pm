package NDTools::INC;

use strict;
use warnings FATAL => 'all';

sub import {
    unshift @INC, substr(__FILE__, 0, length(__FILE__) - 3);
}

1;
