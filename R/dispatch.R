"$.PerlReference" <-
function(obj,name)
{
 function(...) {
  .Perl(as.character(name),..., ref=obj)
 }
}


"[.PerlArrayReference" = "[[.PerlArrayReference" =
function(obj,..., drop = TRUE,  convert = TRUE)
{
 args = list(...)

 # No longer needed as we moved convert to a formal argument.
# if(length(names(args)) && "convert" %in% names(args)) {
#    convert = as.logical(args[["convert"]])
#    args = args[- match("convert", names(args))]
# }
  
 args <- sapply(args, as.integer)
 v <- .Call(RS_PerlArrayElement, obj, args - as.integer(1), as.logical(convert))
 if(!is.null(v) && length(list(...)) == 1) {
   v <- v[[1]]
 }

 v
}

"[.PerlHashReference"  =  "[[.PerlHashReference"  =
function(obj,..., drop = TRUE, convert = TRUE)
{
 args <- sapply(list(...), as.character)
 v <- .Call(RS_PerlHashElement, obj, args, as.logical(convert))
 if(!is.null(v) && length(list(...)) == 1) {
   v <- v[[1]]
 }

 v  
}
