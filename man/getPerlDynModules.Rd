\name{getPerlDynModules}
\alias{getPerlDynModules}
\title{Names of supported dynamically loadable Perl modules}
\description{
  When we embed Perl within R and then load a Perl module
  (into the Perl interpreter) that uses native/compiled code,
  we must have created some special code to allow the Perl interpreter
  to load that DLL/shared object. This is done when the RSPerl
  package is installed. This function returns the names of the
  Perl modules for which this support was added at the time
  of installing this package. It is used primarily
  as a diagnostic tool and to determine if we need to re-install
  the RSPerl package with support for additional modules.
}
\usage{
getPerlDynModules()
}
\value{
  A character vector giving the names of the modules. 
}
\author{Duncan Temple Lang}

\seealso{\code{\link{.PerlPackage}}}
\examples{
 getPerlDynModules()
}
\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
