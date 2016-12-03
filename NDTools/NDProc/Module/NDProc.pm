package NDTools::NDProc::Module::NDProc;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Module";

sub MODINFO { "ndproc - plugin driven nested data processor" }
sub VERSION { "0.01" }

1; # End of NDTools::NDProc::Module::NDProc

__END__

=head1 NAME

ndproc - plugin driven nested data processor

=head1 SYNOPSIS

    ndproc [OPTIONS] <arguments>

=head1 DESCRIPTION

Process nested data structures according provided rules

=head1 OPTIONS

=over 4

=item B<--help|-h>

Print a help message and exit.

=item B<--list-modules|-l>

List available modules.

=item B<--module|-m> E<lt>nameE<gt>

Process using specified module.

=item B<--rules> E<lt>fileE<gt>

Load rules from specified file. May be used several times.

=item B<--verbose|-v> [int]

Increase verbosity, max level - 4.

=item B<--version|-V>

Print version and exit.

=back

=head1 EXAMPLES

Simply merge three files using module 'Merge':

    ndproc -m Merge a.json b.json c.json

=head1 EXIT STATUS

 0   No errors occured.
 1   Generic error code.
 2   I/O Error.

=head1 REPORTING BUGS

Report bugs to L<https://github.com/mr-mixas/NDTools/issues>

=head1 SEE ALSO

L<jq(1)>

L<nddiff(1)>, L<ndpatch(1)>, L<ndquery(1)>

L<Struct::Diff>, L<Struct::Path>, L<Struct::Path::PerlStyle>

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Michael Samoglyadov C<< <mixas at cpan.org> >>.

This program is free software; you can redistribute it and/or modify it
under the terms of GNU General Public License 3 or later versions.
