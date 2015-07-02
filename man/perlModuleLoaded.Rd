\name{perlModuleLoaded}
\alias{perlModuleLoaded}
\title{Determines if Perl module has been loaded}
\description{
  This function attempts to determine if the specified
  Perl module has been loaded within this Perl interpreter
  during the session. It uses the \code{B::Stash} module
  in Perl to do this, but unfortunately this only works
  the first time, apparently and then does not receive updates.
  We hope to remedy this, if possible and then the function will
  serve its intended use which is to help in determining
  when other functions that deal with packages should force them to be loaded.
}
\usage{
perlModuleLoaded(pkgs = character(0))
}
\arguments{
  \item{pkgs}{a character vector giving the names of the Perl modules of
    interest which we wish to determine have been loaded or not.
    If this is the empty character vector (the default), the function
    simply reports the current view of the loaded modules
   }
}
\details{
 This uses \code{B::Stash} and is \code{Seen} variable.
}
\value{
  If \code{pkgs} has a non-zero length, this returns a logical vector
  indicating which of the specified package names has been loaded in the
  Perl interpreter.

  If \code{pkgs} is the empty character vector, this returns the names
  of the Perl modules that have been loaded.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\seealso{
  \code{\link{.PerlPackage}}
  \code{\link{.PerlNew}}
}
\examples{
  
  perlModuleLoaded()
  perlModuleLoaded("Bio::SeqIO")
}
\keyword{programming}
\concept{meta-programming}
\concept{Inter-system interface}
