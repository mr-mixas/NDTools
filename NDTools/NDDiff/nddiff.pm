package NDTools::NDDiff::nddiff;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDDiff";

sub MODINFO { "Generic diff for nested data structures" }
sub VERSION { "0.07" }

1; # End of NDTools::NDDiff::nddiff

__END__

=head1 NAME

nddiff - diff tool for nested data structures

=head1 SYNOPSIS

    nddiff [OPTIONS] <file1> <file2>

=head1 DESCRIPTION

Diff for nested data structures with human friendly (colored)
and machine-readable (JSON) output format.

=head1 OPTIONS

=over 4

=item B<--[no]colors>

On/Off colors for diff.

=item B<--help|-h>

Print a help message and exit.

=item B<--json>

Use JSON as diff format.

=item B<--ignore> E<lt>pathE<gt>

Ignore substructure. This path is used relatively to --path opt. May be used several times.

=item B<--list-modules|-l>

Print list of available diff modules.

=item B<--module|-m> E<lt>nameE<gt>

Use specified diff module.

=item B<--path> E<lt>pathE<gt>

Define path to substructure to deal with. See detailed syntax description
at L<https://metacpan.org/pod/Struct::Path::PerlStyle>

=item B<--[no]pretty>

On/Off pretty-print for JSON. Enabled by default.

=item B<--quiet|-q>

Don't show diff, only exit code shows exists diff or not.

=item B<--verbose|-v> [int]

Increase verbosity, max level - 4.

=item B<--version|-V>

Print version and exit.

=back

=head1 EXAMPLES

Human-friendly diff:

    nddiff a.json b.json

Machine-readable diff:

    nddiff --json a.json b.json

=head1 EXIT STATUS

 0   No errors, no diff.
 1   Generic error code.
 2   I/O Error.
 8   Diff exists.

=head1 REPORTING BUGS

Report bugs to L<https://github.com/mr-mixas/NDTools/issues>

=head1 SEE ALSO

L<diff(1)>, L<sdiff(1)>

L<ndpatch(1)>, L<ndproc(1)>, L<ndquery(1)>

L<Struct::Diff>, L<Struct::Path>, L<Struct::Path::PerlStyle>

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Michael Samoglyadov C<< <mixas at cpan.org> >>.

This program is free software; you can redistribute it and/or modify it
under the terms of GNU General Public License 3 or later versions.
