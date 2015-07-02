
.PerlInit <-
#
# args - command line arguments that are passed to perl_parse
#    These should be "R" "-e" "0" for the minimal effect.
#    Otherwise, they can contain names of files to be read by the
#    perl interpreter.
#
# extensions 
#     the name of a C routine that is responsible for loading
#     the C-level extensions for perl. See perl_parse
#     or p317 of Advanced Perl Programming.
#
# run
#     whether to invoke perl_run() after having processed the command lines.
#     This is useful if we want to execute the scripts read during the perl_parse.
#
function(args = perlInitArgs(), extensions = character(0), run = FALSE, verbose = FALSE,
          loadModules = c("R", "RReferences"))
{
 if(verbose)
   cat("Initializing perl\n")

 setPerlLib(FALSE)
 
 if(commandArgs()[1] == "REmbeddedPerl") {
   setPerlHandler()
   if(verbose)
      cat("Perl is already initialized\n")
   return(TRUE)
 }

 p = .Call(RS_InitPerl, as.character(args), as.character(extensions), as.logical(run))

 setPerlHandler()
 if(verbose)
   cat("Is RS::findModule available?", .PerlExists("RS::findModule"), "\n")

 if(!is.logical(loadModules) || loadModules)
     .PerlPackage(loadModules)

 p
}

setPerlLib =
function(force = FALSE)
{
  ans = FALSE
  if(force || (Sys.getenv("PERL5LIB") == "" && Sys.getenv("PERL5LIB") == "")) {
     val = getPerl5LibValue()
     if(nchar(val)) {
       cur = Sys.getenv("PERL5LIB")
       if(nchar(cur))
         val = paste(cur, val, sep = .Platform$path.sep)
       Sys.putenv("PERL5LIB" = val)
       ans = TRUE
     }
  }
  ans
}  

perlInitArgs <-
function()
{
  c("R", getPerlScript("RS.pl"))
}

.PerlTerminate <-
function(.perl = NULL)
{
  # cat("Ignoring request to terminate perl\n")  
 .Call(RS_FinishPerl, .perl)
}
