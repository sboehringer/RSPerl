.onLoad <- .First.lib <-
function(libname, pkgname) {
  library.dynam("RSPerl", pkgname, libname)
#  args <- paste(paste("-I", Sys.getenv("PERL_XS_R"),sep=""),c("blib/arch", "blib/lib"), sep="/")
#  args <- c("-e", "0")
 .PerlInit()
}

.onUnload =
function(x)
{
 .PerlTerminate()
}
