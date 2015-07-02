.PerlSetArray <-
# sets one or more elements of an array
function(ref, ..., value)
{
  indeces <- sapply(list(...), as.integer)
  if(!is.list(value))
    value <- list(value)

  .Call(RS_PerlSetArrayElements, ref, indeces - as.integer(1), value)
 value
}

"[<-.PerlArrayReference" <-
function(ref, ..., value)
{
 .PerlSetArray(ref, ..., value=value)

 ref
}


.PerlSetHash <-
# sets one or more elements of an array
function(ref, ..., value)
{
  indeces <- sapply(list(...), as.character)
  if(!is.list(value))
    value <- list(value)

  .Call(RS_PerlSetHashElements, ref, indeces, value)

 value
}

"[<-.PerlHashReference" <-
function(ref, ..., value)
{
 .PerlSetHash(ref, ..., value=value)

 ref
}
