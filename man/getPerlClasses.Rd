\name{getPerlClasses}
\alias{getPerlClasses}
\alias{getPerlMethods}
\title{Get class information and methods for a Perl module}
\description{
  These functions retrieve meta-data about a Perl reference object or
  Perl module.  \code{getPerlClasses} retrieves the names of the
  super-classes of the module/class, and optionally all its ancestor
  classes.
  \code{getPerlMethods} retrieves information about the methods
  available in a particular class/module, and again optionally for all
  the ancestor classes.
}
\usage{
getPerlClasses(obj, recursive = TRUE)
getPerlMethods(obj, recursive = TRUE, flat = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{obj}{either a \code{PerlReference} object or a character vector
    giving the name of the Perl module of interest.}
  \item{recursive}{a logical value indicating whether to return
    information about all the ancestor classes (\code{TRUE}) or
    just for this particular class (\code{FALSE}).}
  \item{flat}{a logical value indicating whether to put all the methods
    into a single list of methods, or to keep the methods for each of
    the classes as a separate collection in the list with elements
    indexed by class name.}
}
\details{
 This uses the \code{\link{.PerlStashInfo}} function to find the
 relevant information.
}
\value{
 \code{getPerlClasses} returns a character vector. If \code{recursive}
 is \code{FALSE}, this gives the names of the immediate base classes
 from which the object or module is derived.
 If \code{recursive} is \code{TRUE}, then the character vector contains
 the names of all the ancestor classes.

 \code{getPerlMethods} returns a list. If \code{recursive} is
 \code{FALSE}, this is the subset of the elements in the stash table
 (symbol table hash) for the Perl
 module which are code objects, i.e. \code{PerlCodeReference} objects.
 If \code{recursive} is \code{TRUE} and \code{flat} is \code{TRUE}
  (the default), methods for this module/class and all the ancestor
  modules are returned in a single collection, all mixed together.
  If \code{flat} is \code{FALSE} and \code{recursive} is \code{TRUE},
  then the result is a list with one element for each ancestor class.
  The elements are indexed by class name and contain the list of
  code objects within that stash. 
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}
\seealso{
 \code{\link{.PerlStashInfo}}
 \code{\link{.PerlPackage}}
}
\examples{
 getPerlClasses("Text::Abbrev")

if(FALSE) {#XXX  seems to cause problems in R CMD check, but not when
           #  run manually!
 getPerlClasses("IO::Dir")
 getPerlMethods("IO::Dir")
}
}
\keyword{programming}
\concept{Perl}
\concept{Inter-system Interface}

