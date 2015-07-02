use R;

#R::initR();
#R::library("RSPerl");

# 
# Call from with R as 
# library(RSPerl)
# .PerlFile("basicMatrix.pl")
# .Perl("foo")

# This tests getting the scalar references to a class.

sub foo {
 $x = [1..10];
 $m = R::print($x);
 $y = 1.2;
 $m = R::print($y);

 # Check mixture with more than 2 elements of type real and integer.
 $x = [ 1, 2.0, 3.1, 4.2];
 R::callWithNames("plot", { x => $x, ylim => [0, 5.3]}); 

 return(1);
}
