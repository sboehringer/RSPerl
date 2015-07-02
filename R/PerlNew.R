.PerlNew <-
function(klass, ..., .convert = FALSE, .perl=NULL, .new = "new", .load = FALSE) # Perhaps make this TRUE!
{
  if(is.character(klass) && .load) 
    .PerlPackage(klass)

  ref <- .Perl(as.character(.new), ..., ref = klass, convert = .convert, .perl = .perl)
  ref$class <- klass
 ref
}


.PerlNewTable <-
function(..., name=NULL)
{
  args <- list(...)
  if(length(args) > 0)
     nms <- names(args)
  else
    nms <- character(0)

  .Call(RS_newPerlTable, args, nms, as.character(name))
}

.PerlNewArray <-
function(..., name=NULL)
{
  args <- list(...)
  .Call(RS_newPerlArray, args, as.character(name))
}
