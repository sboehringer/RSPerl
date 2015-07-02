 
.PerlExpr("@a = (1,2,3);")
.PerlGet("a", T)

.PerlExpr("%b = ('a',1,'b',2,'c',3);"); 
.PerlGetTable("b")

.PerlFile(system.file("examples", "hier.pl", package = "RSPerl"))
o <- .PerlNew("hier")
o[1]
o[2]

