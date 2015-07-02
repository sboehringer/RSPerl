.PerlExpr <-
function(expr, .convert = TRUE, .perl=NULL)
{
 .Call(RS_PerlEvalString, as.character(expr), .perl, as.logical(.convert),
                             as.integer(NA))
}

.PerlFile <-
function(fileName, run = TRUE, extensions = character(0), .perl=NULL)
{

 if(!file.exists(fileName))
  stop(paste("No such file", fileName))

   # The initial R takes the place of the ARGV[0].
 fileName <- c("R",  path.expand(fileName))
 
 .Call(RS_PerlEvalFile, as.character(fileName), as.logical(run), as.character(extensions), .perl)
}

.Perl <-
#
#
#
#
function(routine, ..., convert = TRUE, array = TRUE, pkg = NULL, ref = NULL, .sigs=character(),
          .args = list(...), .perl= NULL)
{
 if(!missing(ref) & !inherits(ref, "PerlReference")) {
   .args <- c(as.character(ref), .args)
   ref <- TRUE
 }

 if(!missing(pkg)) {
   tmp <- .PerlGetCode(routine, pkg)
   if(is.null(routine))
     stop(paste("No such Perl method or subroutine",routine,"in module",pkg))
   routine <- tmp
 }

 .Call(RS_PerlCallModified, routine, .args, convert, as.logical(array), ref, .perl)
}

