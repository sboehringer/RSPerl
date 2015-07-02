.PerlFile("tests/method.pl"); 
m <- .PerlExpr("$a = new Mine('red', 'green', 'blue');"); 
.Perl("Display",1, ref=m)

.Perl("PrintID", ref="Mine")