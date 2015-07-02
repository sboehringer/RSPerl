=head1 DESCRIPTION

A simple test of the initialization mechanism of R within a Perl process
and passing command line arguments to it. We check here that we can retrieve
those command line arguments from within Perl via the S function
C<commandArgs>.

=cut

use R;

R::initR("--gui=NONE", "x", "y", "z");

@args = R::call("commandArgs");

$i = 1;
foreach $x (@args) {
    print $i++, ") ", $x, "\n";
}

