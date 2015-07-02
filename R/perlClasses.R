getPerlClasses =
  #
  # XXX put names of the source class
  #
function(obj, recursive = TRUE)
{
  if(inherits(obj, "PerlReference")) 
     obj = class(obj)[1]

  # If we are given a reference to the package, want to deal with that properly
  obj = as.character(obj)
  stash = .PerlStashInfo(obj, .convert = FALSE)

  ans = unlist(stash[["ISA"]])
    
  if(recursive && length(ans)) 
    ans = c(ans, unlist(lapply(ans, getPerlClasses)))
    
  unique(ans)
}  


getPerlMethods =
function(obj, recursive = TRUE, flat = TRUE)
{
  if(inherits(obj, "PerlReference")) 
     obj = class(obj)[1]

  els = .PerlStashInfo(obj)
  els[sapply(els, inherits, "PerlCodeReference")]

  if(recursive) {
    classes = getPerlClasses(obj)
    m = lapply(classes, getPerlMethods, recursive = FALSE)
    if(flat)
       els = append(els, unlist(m, recursive = FALSE))
    else {
       els = list(els)
       names(els) = obj
       els[classes] = m
    }
  }

  els
}

