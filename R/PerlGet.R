.PerlGet <-
function(what, .convert = TRUE, .perl=NULL, ...)
#  isArray = FALSE, pkg=NULL, .sig=character(0)
{
  UseMethod(".PerlGet")
}

.PerlGet.default <-
function(what, .convert = TRUE, .perl=NULL, ..., isArray = FALSE, pkg=NULL, .sig=character(0))
{
 .Call(RS_PerlGet, as.character(what), as.logical(isArray), .perl)
}


.PerlGetStash =
function(code)
{
 if(!inherits(code, "PerlCodeReference"))
   stop(".PerlGetStash requires a PerlCodeReference")
 ans = .Call(RS_getStashFromCode, code)
 class(ans) = c("PerlStashReference", class(ans))

 ans
}


.PerlGetTable <-
#
# what can be a string identifying a Perl variable
# or a PerlHashReference object.
#
function(what, .convert = TRUE, .perl = NULL, ...)
{
 val <- .Call(RS_getHV, what, .convert, .perl)

 val
}

.PerlGet.PerlHashReference <- .PerlGetTable

.PerlGetArray <-
function(what, .convert = TRUE, .perl = NULL, ..., apply = NULL)
{
 val <- .Call(RS_getAV, what, .convert, apply, .perl)

 val
}

.PerlGet.PerlArrayReference <- .PerlGetArray

.PerlGetCode <-
function(name, pkg=character(0), .perl = NULL, asFunction = FALSE) 
{
 if(!missing(pkg)) {
    if(!perlModuleLoaded(pkg))
      .PerlPackage(pkg)
   name <- paste(pkg, name, sep="::")
 }

 pc <- .Call(RS_getCV, as.character(name), .perl)

 if(is.null(pc))
   return(NULL)
 
 if(asFunction) {
   k <- function(...) {
     .Perl(pc, ...)
   }
   return(k)
 } else {
    pc$name <- name
    pc$package <- pkg
 }

 pc
}
