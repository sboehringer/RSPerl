.PerlInterpreter <-
function(all = FALSE)
{
  .Call(RS_getPerlInterpreter, as.logical(all))
}
