package App::NDTools::Complete;

use strict;
use warnings FATAL => 'all';

use Getopt::Long qw();

use Data::Dumper;

BEGIN {
    no warnings 'redefine';

    print STDERR Dumper \@ARGV;

    sub Getopt::Long::GetOptionsFromArray(@) {
        my ($argv, @optionlist) = @_; # local copy of the option descriptions
        my %opctl = (); # table of option specs

        print STDERR "Heeere\n";

        while (@optionlist) {
            my $opt = shift @optionlist;

            my ($name, $orig) = Getopt::Long::ParseOptionSpec ($opt, \%opctl);
            unless (defined $name) {
                shift (@optionlist) if (@optionlist && ref($optionlist[0]));
                next;
            }

            #print STDERR Dumper [$name, $orig];

        }
        #print STDERR Dumper $argv;
        #print STDERR Dumper \%opctl;

        map { print "--$_\n" } sort keys %opctl;
        print STDERR "Heeere <<<<\n";
        exit 1;
    }
}

1;
