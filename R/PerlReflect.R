perlModuleLoaded =
  #
  # Currently, this has problems the second time around that we look at Seen
  #
  #
function(pkgs = character(0))
{
 b = .PerlPackage("B::Stash")
 els = names(b$stash[["Seen"]])

 base = gsub("\\.pm$", "", els)
 if(FALSE) { # if we were working with the actual file names rather than the keys.
   inc = .PerlGet("INC", TRUE)
     # Discard the .  May need to be careful about other .'s in our strings
   inc = inc[inc != "."]
   base = gsub(paste("(", paste(inc, collapse = "|"), ")", .Platform$file.sep, sep = ""), "", els)
 }

 base = gsub(.Platform$file.sep, "::", base)

 if(length(pkgs))
   pkgs %in% base
 else
   base
}  


.PerlStashInfo <-
function(pkg = "main", .convert = TRUE, .perl = NULL, .load = TRUE)
{
 if(inherits(pkg, "PerlPackage"))
   pkg = pkg$name
 else if(inherits(pkg, "PerlReference"))
   pkg = class(pkg)[1]
 else if(.load && pkg != "main" && !perlModuleLoaded(pkg))    # Force the loading
   .PerlPackage(pkg) # could get the stash from this, but need to obey .convert here.

 if(pkg == "main" && .convert) {
   warning("cannot convert elements in the main stash because of potential self-references. Using .convert = FALSE")
   .convert = FALSE
 }
  
 ans = .Call(RS_getStash, as.character(pkg), .convert, .perl)

 if(is.null(ans))
   stop("can't get stash for module ", pkg, ". Is it loaded in the Perl interpreter")
 
 if(!.convert)
    class(ans) = c("PerlStashReference", class(ans))

 ans
}

.PerlObjects <- function(pkg = "main", .perl= NULL)
{
   names(.PerlStashInfo(pkg, FALSE, .perl, .load = ifelse(pkg == "main", FALSE, TRUE)))
}

.PerlTypes <- c("CV" = 0, "AV" = 1, "HV" = 2, "SV" = 3)

.PerlExists <-
function(name, pkg=NULL, type = "SV")
{
  if(is.character(type)) {
    type <- pmatch(type, names(.PerlTypes)) -1
    if(is.na(type))
       stop("Incorrect type specification")
  }

  .Call(RS_PerlExists, as.character(name), pkg, as.integer(type))
}


.PerlType <-
function(ref, pkg=NULL, perl=NULL)
{
 .Call(RS_getPerlType, ref, as.character(pkg), perl)
}
