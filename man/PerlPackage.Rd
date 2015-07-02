\name{.PerlPackage}
\alias{.PerlPackage}
\alias{.PerlPackageExists}
\alias{.PerlFindPackage}
\title{Find or load a Perl Package into the Perl Interpreter}
\description{
This collection of functions allows one to determine
if a particular Perl module is available
and to load it into the current Perl interpreter,
making its exported sub-routines, classes and objects 
available within the R session.
The load is equivalent to calling \code{use module;}
but with checks to ensure the module exists.
}
\usage{
.PerlPackage(pkg, load = TRUE, .extensions=character(0), .perl=NULL,
              simplify = TRUE)
}
\arguments{
  \item{pkg}{the name of the Perl module to be loaded.}
  \item{load}{a logical value indicating whether the module
should be loaded or un-loaded. Only \code{TRUE} (i.e. load)
currently works.}
  \item{.extensions}{an optional  string  identifying
 the name of a C routine which is to be used to load Perl modules
that require C code. See the overview.nw for a description of
the C routine and how to automatically generate it.
}
  \item{.perl}{an optional object identifying which Perl interpreter 
    into which the module will be loaded}
  \item{simplify}{a logical value which, if \code{TRUE} and the number
    of modules to be loaded (i.e. the length of \code{pkg} is 1),
    returns just the PerlPackage object.
    If more than one package is loaded in this call, a list
    with such an object for each package is returned regardless of the
    value of \code{simplify}.
  }
}
\value{
  \code{.PerlPackage} now returns an S3 object of class
  \code{PerlPackage}
  which gives the name of the Perl module and
  also a reference to its stash table (symbol table hash) of methods, etc.
  This is  a list whose elements are named
  \code{name} and \code{stash}.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}
\note{One of the reasons for adding the \code{.PerlPackageExists}
function is to allow us to check for a package before attempting
to load it as that results in a terminal error.

Also note that these functions illustrate a  mechanism 
for adding further functionality to this package by 
implementing Perl sub-routines and calling them.
Given the general \code{\link{.Perl}} foundation as a mechanism for calling
Perl code, one can chose where to best implement functionality needed in R --
in R or in Perl.}
\seealso{
\code{\link{.PerlStashInfo}}
\code{\link{.PerlObjects}}
}

\examples{
\dontrun{
  # Attempts to the News::NNTPClient package.
  # This may not be available on some systems,
  # but should fail gracefully.
 try(.PerlPackage("News::NNTPClient"))

 try(.PerlPackage("Date::Manip"))

 if(.PerlPackageExists("Date::Manip"))
   .PerlPackage("Date::Manip")
}
}
\concept{Perl}
\concept{Inter-system interface}
\keyword{interface}