package NDTools::HMBehs;

use 5.006;
use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);

use Hash::Merge qw(_merge_hashes);

our $VERSION = '0.05'; # Don't forget to change in pod below

our @EXPORT_OK = qw(
    L_OVERRIDE
    R_OVERRIDE

    L_REPLACE
    R_REPLACE
);

use constant L_OVERRIDE => {
    'SCALAR' => {
        'SCALAR' => sub { $_[0] },
        'ARRAY'  => sub { $_[0] },
        'HASH'   => sub { $_[0] },
    },
    'ARRAY' => {
        'SCALAR' => sub { [ @{ $_[0] } ] },
        'ARRAY'  => sub { [ @{ $_[0] } ] },
        'HASH'   => sub { [ @{ $_[0] } ] },
    },
    'HASH' => {
        'SCALAR' => sub { $_[0] },
        'ARRAY'  => sub { $_[0] },
        'HASH'   => sub { _merge_hashes( $_[0], $_[1] ) },
    },
};
Hash::Merge::specify_behavior(L_OVERRIDE, "L_OVERRIDE");

use constant R_OVERRIDE => {
    'SCALAR' => {
        'SCALAR' => sub { $_[1] },
        'ARRAY'  => sub { $_[1] },
        'HASH'   => sub { $_[1] },
    },
    'ARRAY' => {
        'SCALAR' => sub { [ @{ $_[1] } ] },
        'ARRAY'  => sub { [ @{ $_[1] } ] },
        'HASH'   => sub { [ @{ $_[1] } ] },
    },
    'HASH' => {
        'SCALAR' => sub { $_[1] },
        'ARRAY'  => sub { $_[1] },
        'HASH'   => sub { _merge_hashes( $_[0], $_[1] ) },
    },
};
Hash::Merge::specify_behavior(R_OVERRIDE, "R_OVERRIDE");

use constant L_REPLACE => {
    'SCALAR' => {
        'SCALAR' => sub { $_[0] },
        'ARRAY'  => sub { $_[0] },
        'HASH'   => sub { $_[0] },
    },
    'ARRAY' => {
        'SCALAR' => sub { $_[0] },
        'ARRAY'  => sub { $_[0] },
        'HASH'   => sub { $_[0] },
    },
    'HASH' => {
        'SCALAR' => sub { $_[0] },
        'ARRAY'  => sub { $_[0] },
        'HASH'   => sub { $_[0] },
    },
};
Hash::Merge::specify_behavior(L_REPLACE, "L_REPLACE");

use constant R_REPLACE => {
    'SCALAR' => {
        'SCALAR' => sub { $_[1] },
        'ARRAY'  => sub { $_[1] },
        'HASH'   => sub { $_[1] },
    },
    'ARRAY' => {
        'SCALAR' => sub { $_[1] },
        'ARRAY'  => sub { $_[1] },
        'HASH'   => sub { $_[1] },
    },
    'HASH' => {
        'SCALAR' => sub { $_[1] },
        'ARRAY'  => sub { $_[1] },
        'HASH'   => sub { $_[1] },
    },
};
Hash::Merge::specify_behavior(R_REPLACE, "R_REPLACE");

1;

__END__

=head1 NAME

NDTools::HMBehs -- Collection of extra behaviors for HASH::Merge

=head1 VERSION

Version 0.05

=head1 SYNOPSIS

    use Hash::Merge qw(merge);
    use NDTools::HMBehs;

    Hash::Merge::specify_behavior(R_OVERRIDE);

    $result = merge($ref1, $ref2);

=head1 EXPORT

Nothing exports by default.

=head1 BEHAVIORS

=over 4

=item L_OVERRIDE, R_OVERRIDE

Merge hashes, override arrays and scalars: left and right precedence

=item L_REPLACE, R_REPLACE

Don't merge, simply replace one thing by another. Left and right precedence.

=back

=head1 SEE ALSO

L<Hash::Merge>

=head1 LICENSE AND COPYRIGHT

Copyright 2016,2017 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut
