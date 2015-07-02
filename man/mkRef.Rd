\name{mkRef}
\alias{mkRef}
\title{Create a reference to a Perl object representing the given R value}
\description{
 This function is necessary when a Perl method/subroutine requires a
 reference to an object for which a simple scalar value would
 ordinarily appear  to suffice.
 This is the case, for example, when the method/routine modifies its
 input.  See \code{find_ipaddrs} in the \code{NetAddr::IP::Find} Perl
 module.
 This takes the R object, converts it to Perl and then creates a
 reference to it in the Perl sense and returns an opaque data type in R
 to that reference for use in further computations.
}
\usage{
mkRef(obj)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{obj}{any R object which can be converted to a Perl value.}
}
\value{
  A \code{PerlReference} object with the appropriate specialized classes
  depending on the type of \code{obj}.
  It may be returned as a \code{PerlReferenceReference} object
  depending on the type of the R object.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\seealso{
  \code{\link{.Perl}}
  \code{\link{.PerlNew}}  
}
\examples{

\dontrun{
  try( {
    .PerlPackage("NetAddr::IP::Find")
    txt = "Some text with 128.32.135.50 and other IP address such as www.omegahat.org and 192.168.0.2 and something stupid like 123.456.789.1";
    r = mkRef( txt )
    .Perl('find_ipaddrs', r, function(ip, orig) cat(ip$addr(), "\n"), pkg = "NetAddr::IP::Find")
  })
}
}
\keyword{programming}
\keyword{interface}
\concept{Inter-system interface}

