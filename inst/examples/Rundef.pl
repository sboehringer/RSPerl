=head1 DESCRIPTION
 This script checks that NULL values are being handled correctly by
 the R-Perl interface when calling from Perl.

=head1 SYNOPSIS
  
  perl Rundef.pl

 Make certain to have the LD_LIBRARY_PATH and PERLLIB environment
 values set appropriately to find the R library and modules.

=cut

use R;
use RReferences;

R::initR();
R::library("RSPerl");

print "is.null(undef) ", R::call("is.null", undef), "\n";

$v = R::eval("NULL");
print "R::eval(NULL) returns undef? ", (defined $v ? "no" : "yes"), "\n";


R::eval("checkNull <<- function(...) { print(list(...)); x <- sapply(list(...), is.null); print(x) ; x}");

print "First call to checkNull\n";
@x = R::call("checkNull", 1, undef, 2);
for $i (@x) { print $i,"\n";}

print "Second call to checkNull\n";
@x = R::call("checkNull", undef, 1, 2);
for $i (@x) { print $i,"\n";}
