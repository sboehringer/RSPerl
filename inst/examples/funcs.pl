use R;

use RReferences;

=head1 DESCRIPTIOPN

 Example of using references to R functions as if they were
 Perl sub-routines. This is just syntactic sugar for 
 R::call().
 When used with function references, rather than named function references,
 one gets the benefit of avoiding lookups and accessing anonymous functions.

=cut

&R::initR();
&R::library("RSPerl");

$f = RNamedFunctionReference->new("print");

 # Call the R function associated with this reference.
$f->("A string in perl");

 # Now call cat() with a few arguments.
$f = RNamedFunctionReference->new("cat");
$f->(1, 3, "foo", "\n");



$f->(1, 3, "\n");

$g = foo;

$g->();

sub foo {
    print "In foo\n";
}
