names.PerlHashReference <-
function(x,...)
{
  .PerlNames(x)
}

.PerlNames <-
function(hv)
{
  .Call(RS_PerlNames, hv)
}
