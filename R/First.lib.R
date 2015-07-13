#.onLoad <- .First.lib <-
.onLoad <- function(libname, pkgname) {
	l = .libPaths()[1];
	Sys.setenv(PERL5LIB = sprintf(
		'%s/RSPerl/scripts:%s/RSPerl/perl/x86_64-linux-thread-multi/:%s',
		l, l, Sys.getenv('PERL5LIB'))
	);
	library.dynam("RSPerl", pkgname, libname)
	#  args <- paste(paste("-I", Sys.getenv("PERL_XS_R"),sep=""),c("blib/arch", "blib/lib"), sep="/")
	#  args <- c("-e", "0")
	.PerlInit()
}

.onUnload = function(x) {
	.PerlTerminate()
}
