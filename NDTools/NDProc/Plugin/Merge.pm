package NDTools::NDProc::Plugin::Merge;

use strict;
use warnings FATAL => 'all';
use parent "NDTools::NDProc::Plugin";

sub MODINFO { "Merge structures according provided rules" }
sub VERSION { "0.01" }

1; # End of NDTools::NDProc::Plugin::Merge

__END__

=head1 NAME

Merge - merge structures according provided rules

=head1 OPTIONS

=over 4

=item B<--ignore> E<lt>pathE<gt>

Skip specified structure parts. May be used several times.

=item B<--path> E<lt>pathE<gt>

Path in the structure to merge. Whole structure will be merged if
omitted. Paths '' or '{}' or '[]' means "whole" struct, and should be
used as first merge target if whole struct must be merged and then
some parts merged with other options. May be specified several times.

=item B<--[no]strict>

Fail if specified path doesn't exists in prerequisite. Enabled by default.

=item B<--style> E<lt>L_OVERRIDE|R_OVERRIDEE<gt>

Merge style.

=over 8

=item B<L_OVERRIDE>, B<R_OVERRIDE>

Objects merged, lists overrided, left and right precedence.

=back

Default is B<R_OVERRIDE>

=back

=head1 SEE ALSO

L<ndproc(1)>, L<ndproc-modules>

L<nddiff(1)>, L<ndquery(1)>, L<Struct::Path::PerlStyle>

