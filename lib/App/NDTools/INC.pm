package App::NDTools::INC;

sub import {
    unshift @INC, substr(__FILE__, 0, -3);
}

1;
