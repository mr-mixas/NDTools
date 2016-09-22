package NDTools::NDDiff::nddiff;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDDiff";

sub MODINFO { "Generic diff for nested data structires" }
sub VERSION { "0.05" }

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

=item B<--[no]colors>

On/Off colors for diff.

=item B<--help|-h>

Print a help message and exit.

=item B<--list-modules|-l>

Print list of available diff modules.

=item B<--module|-m> E<lt>nameE<gt>

Use specified diff module.

=item B<--path> E<lt>pathE<gt>

Define path to substructure to deal with. See detailed syntax description
at L<https://metacpan.org/pod/Struct::Path::PerlStyle>

=item B<--verbose|-v> [int]

Increase verbosity, max level - 4.

=item B<--version|-V>

Print version and exit.

=back

=head1 EXAMPLES

Simple diff:

    nddiff a.json b.json

=head1 REPORTING BUGS

Report bugs to L<https://github.com/mr-mixas/NDTools/issues>

=head1 SEE ALSO

L<diff(1)>, L<sdiff(1)>

L<Struct::Diff>, L<Struct::Path>, L<Struct::Path::PerlStyle>

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Michael Samoglyadov C<< <mixas at cpan.org> >>.

This program is free software; you can redistribute it and/or modify it
under the terms of GNU General Public License 3 or later versions.
