=head1 DESCRIPTION
 This tests the ability to add user-defined Perl sub-routines/methods
 to the conversion mechanism from R to Perl.
 Run this from R as
  .PerlFile(system.file("examples", "convert.pl", package = "RSPerl"))
  .Perl("bar")
=cut

use R;
use RReferences;

R::initR();


sub foo {
    foreach $a (@_) {
	print $a, "\n";
    }
}

sub match {
    my $obj = shift;
    print "In match ", $obj, ", type ", ref($obj), "\n";

    return(1);
}

sub convert {
    my $obj = shift;
    print "In convert. Returning array.\n";
    return([1, 2]);
}

print "Setting coverter\n";
R::setConverter(\&match, \&convert, "A simple Perl routine conversion", 1);

print "Defining R function\n";
R::eval("mgen <<- function() { o <- list(a=1, b='xyz') ; class(o) <- 'Duncan' ; o}");


sub bar {
  my $x = R::call("mgen");
  print "Result: ", $x, " ", ref($x), "\n";
  1;
}

 bar();

