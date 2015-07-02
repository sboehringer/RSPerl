.PerlDiscard <-
function(obj, asVariable = TRUE, .perl=NULL)
{
  .Call(RS_discardPerlForeignReference, obj)
}


.PerlReferenceObjects <-
function(which = NULL) 
{
  which <- as.character(which)
 .Call(RS_GetPerlReferenceObjects, which)
}

.PerlReferenceCount <-
function()
{
  vals <- .Call(RS_PerlReferenceCount)
  names(vals) <- c("current", "total")

 vals
}


mkRef =
function(obj)
{
#  .PerlPackage("R")
#  .Perl("mkRef", obj, pkg = "R", convert = FALSE)
  .Call(R_makePerlReference, obj, PACKAGE = "RSPerl")
}
