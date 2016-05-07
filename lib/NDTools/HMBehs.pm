package NDTools::HMBehs;

use 5.006;
use strict;
use warnings FATAL => 'all';
use parent 'Exporter';

use Hash::Merge qw(_merge_hashes);

our $VERSION = '0.01'; # Don't forget to change in pod below
our @EXPORT = qw(
    HM_OVERRIDE
);

use constant HM_OVERRIDE => {
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

1;

__END__

=head1 NAME

NDTools::HMBehs -- Collection of extra behaviours for HASH::Merge

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Hash::Merge qw(merge);
    use NDTools::HMBehs qw(HM_OVERRIDE);

    Hash::Merge::specify_behavior(HM_OVERRIDE);

    $result = merge($ref1, $ref2);

=head1 EXPORT

Nothing expoert by default.

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut
