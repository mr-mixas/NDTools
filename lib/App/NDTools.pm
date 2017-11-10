package App::NDTools;

our $VERSION = "0.4.8";

=head1 NAME

ndtools - diff/patch/process/query command line tools for nested data structures

=begin html

<a href="https://travis-ci.org/mr-mixas/NDTools"><img src="https://travis-ci.org/mr-mixas/NDTools.svg?branch=master" alt="CI"></a>

=end html

=head1 SYNOPSIS

    nd* --help|--version
    nd* [OPTIONS] <arguments>

See exact list of options, examples and exit codes for each tool in it's man page.

=head1 DESCRIPTION

Nested structures are everywhere and often requires quite complex processing,
this tools aimed to solve some "pain in the neck" cases without writing any code.

=head1 TOOLS

=over 4

=item B<nddiff>

Diff tool with human friendly (colored, brief) and machine readable (JSON) output.

=item B<ndpatch>

Apply diff to structure.

=item B<ndproc>

Process structure using rules. Extendable by modules.

=item B<ndquery>

Inspect structure or dump it's parts.

=back

=head1 INSTALL

 git clone git@github.com:mr-mixas/NDTools.git
 cd NDTools
 make depends dist
 sudo dpkg -i ndtools*.deb

=head1 BUGS

Report bugs to L<https://github.com/mr-mixas/NDTools/issues>

=head1 SEE ALSO

L<nddiff(1)>, L<ndpatch(1)>, L<ndproc(1)>, L<ndquery(1)>

L<jq(1)>

L<Struct::Diff>, L<Struct::Path>, L<Struct::Path::PerlStyle>
