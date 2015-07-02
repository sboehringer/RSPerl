.PerlPackage <-
function(pkg, load = TRUE, .extensions=character(0), .perl=NULL, simplify = TRUE)
{
 if(!load)
    stop("Cannot yet unload a package.")
  
 ans =
   lapply(pkg,
        function(pkg) {
                 # tests/findModule.pl had better be loaded here already.
                 #if(!force && !.PerlPackageExists(pkg))
                 #     stop(paste("No perl module named", pkg))
           cmd <- paste("use", pkg, ";")
           ans = .PerlExpr(cmd, .perl=.perl)

           if(is.null(ans)) {
             structure(list(name = pkg,
                            stash = .PerlStashInfo(pkg, .convert = FALSE, .load = FALSE) # avoid reloading!
                  ),
             class = "PerlPackage")
             #XXX when we create an instance of an object, the contents of the stash will change.
           } else
             NULL
         })

   if(simplify && length(pkg) == 1)
     ans = ans[[1]]
   else
     names(ans) = pkg

   invisible(ans)
}

.PerlPackageExists <-
function(pkg)
{
 is.character(.PerlFindPackage(pkg))
}

.PerlFindPackage <-
function(pkg)
{
    # Shouldn't have to check here, but for some reason
    # in make check, the RS.pl file is not getting read
    # during the .PerlInit()
  if(!.PerlExists("RS::findModule")) 
     .PerlFile(getPerlScript("RS.pl"))

  .Perl("RS::findModule",as.character(pkg))
}
