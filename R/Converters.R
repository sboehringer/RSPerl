getNumPerlConverters <-
#
# Returns the number of converters
# registered internally in a C list/table
# for performing the conversion between R and Java. 
#   F represents from Java to R,
#   T represents from Java to R.
# This is vectorized in the type or direction of converter.

# By default, it returns both.

function(which = c(fromPerl = FALSE, toPerl = TRUE))
{
 ans <- integer(0)
 for(i in which)
  ans <- c(ans, .Call(RPerl_getNumConverters, as.logical(i))) 

 names(ans) <- names(which)

 ans
}


getPerlConverterDescriptions <-
function(which = c(fromPerl = FALSE, toPerl = TRUE))
{
 ans <- vector("list", length(which))
 for(i in 1:length(which)) {
  ans[[i]] <- .Call(RPerl_getConverterDescriptions, as.logical(which[i]))
 }

 names(ans) <- names(which)

 ans
}


addConverter <-
function(match, converter, fromPerl = TRUE, class = NULL, description = NULL, autoArray = TRUE)
{
  .Call(RPerl_addConverter,   match, converter,
                              as.logical(fromPerl),
                              as.character(class),
                              as.character(description),
                              as.logical(autoArray))
}

removeConverter <-
function(id, fromPerl = TRUE)
{
  if(is.numeric(id))
    id <- as.integer(id)
  
  .Call(RPerl_removeConverter, id, fromPerl, is.character(id))
}  
