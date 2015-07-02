foreignReference <-
#
# Create an object that is used to represent a local R object
# in a call to a foreign system (Java), optionally specifying
# a name by which it is to be stored locally and known externally
# and the name of one or more classes/interfaces that should be used
# to represent it. 
# The last of these is interpreted by the remote system
function(obj, id = NULL, className = NULL, targetClasses = NULL, register = TRUE)
{
 ref <- list(id=as.character(id), 
             value=obj, 
             className=as.character(className), 
             targetClasses=as.character(targetClasses))

 class(ref) <- ifelse(missing(id), "AnonymousRReference", "NamedRReference")

  if(register) {
    ref <- getPerlHandler()$addReference(ref)
  }

 ref
}
