.PerlUndef <-
function(name, scalar = FALSE, array = FALSE, table = FALSE, sub = FALSE, pkg = NULL, .perl = NULL)
{
 if(missing(scalar) & missing(array) & missing(table) & missing(sub))
  .Call(RS_remove, as.character(name), .perl)

  which <- as.logical(c(scalar, array, sub, table))
  names(which) <- c("scalar", "array", "table", "sub")

  .Call(RS_PerlUndef, as.character(name), which, NULL)
}
