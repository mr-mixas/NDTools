package NDTools::NDDiff::nddiff;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDDiff";

sub MODINFO { "Generic diff for nested data structires" }
sub MODNAME { "nddiff" }
sub VERSION { "0.03" }

1; # End of NDTools::NDDiff::nddiff

__END__

=head1 NAME

nddiff - Diff for nested data structures

=head1 SYNOPSIS

    nddiff [OPTIONS] <file1> <file2>

=head1 DESCRIPTION

Diff for nested data structures

=head1 OPTIONS

=over 4

=item B<--help|-h>

Print a help message and exit.

=item B<--module|-m> E<lt>nameE<gt>

Use specified diff module.

=item B<--verbose|-v> [int]

Increase verbosity, max level - 4.

=item B<--version|-V>

Print version and exit.

=back

=head1 LIMITATIONS

LSC algorithm for arrays not implemented yet (items compared by their position). This means
if there is a change in the middle of a list, then all next items will be showed as changed.

=head1 EXAMPLES

Simple diff:

    nddiff a.json b.json
