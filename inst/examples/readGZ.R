# dyn.load(system.file("libs", "RSPerl.so", package = "RSPerl"), local = FALSE)

library(RSPerl)
.PerlInit()

.PerlPackage(c("IO::File", "IO::Uncompress::AnyUncompress"))
f = "/home/duncan/Projects/org/omegahat/Interfaces/Perl/tests/test.gz"

k =.PerlNew("IO::Uncompress::AnyUncompress", f)
