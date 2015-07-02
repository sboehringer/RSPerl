library(RSPerl); .PerlInit()
.PerlPackage("Bio::DB::GenBank")
gb = .PerlNew("Bio::DB::GenBank")
z = .PerlStashInfo(class(gb)[1])
.Call("RS_getStashFromCode", z[[1]])

