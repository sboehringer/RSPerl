referenceHandlerGenerator <- 
#
# Closure generator that creates an object to be passed as the  
# database mechanism for storing foreign references, and also
# perform the dispatching of the calls to these references.
#
function() 
{
    # used to compute a unique identifier
  total <- 0
  references <- list()

  createReference <- function(obj, register = TRUE) {
   r <- foreignReference(obj, register=register)
   return(r)
  }

  addReference <- 
     # add a reference to the database.
     #
   function(obj) {
     if(length(obj$id) == 0) {
        total <<- total + 1       
        key <- as.character(total)
        obj$id <- key
      } else 
        key <- obj$id

     references[[key]] <<- obj


    invisible(obj)
  }

  getReference <- function(id, asIs = FALSE) {
    tmp <- references[[id]]
    if(!asIs)
      tmp <- tmp$value
    return(tmp)
  }

  remove <- 
    # Delete a reference from the database by specifying the object
    # (i.e. the reference) or the identifier. 
  function(id) {
   if(!is.na(match("foreignReference",class(id)))) {
     key <- id$id
   } else
     key <- as.character(id)

    which <- match(key, names(references))
    if(is.na(which))
      return(FALSE)

    references <<- references[-which]

    TRUE
  }

  handler <- function(id, methodName, returnType, signature, javaObject, args, stackCount = -1)
  {
    restart(TRUE)
    stackCount <- stackCount + 1
    if(stackCount > 0) {
      return(list(NULL, paste("Error in the Perl handler invocation of",methodName,"for",id)))
    }

      # resolve the reference
     obj <- references[[id]]
     
      # Now, if it is an foreignReference object, look for its value field.
      # That is what we will invoke the function on or in.
     obj <- obj$value

       # If the value is a list and it has a function stored using the methodName,
       # we'll call it. Otherwise, we just look for a global function and then 
       # put the object onto the front of the argument list. We do this iff
       # obj is non-null. This allows data-less methods to be used.
     if(is.function(obj)) {
        f <- obj
     } else if(is.list(obj) && !is.null(obj[[methodName]]) && is.function(obj[[methodName]])) {
       f <- obj[[methodName]]
     } else {
       f <- get(methodName, mode="function")
       if(!is.null(obj))
        args <- c(obj, args)
     }

       # Create the call by creating an expression with the unravelled arguments
       # used rather than treating them as a single argument which is a list.
       # I imagine there is a function that can do this expansion, but I can't
       # recall it. And since we already have exactly that code in C for other purposes,
       # we use it.
      ans <- eval(.Call("RJava_createCall", f, args))

   return(list(ans))
  }

  return(list(handler=handler, 
              createReference = createReference, 
              addReference = addReference, 
              remove=remove,
              getReference = getReference,
              references=function() {references}, 
              total=function() {total}
             )
        )
}
