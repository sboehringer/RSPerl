\name{.PerlType}
\alias{.PerlType}
\title{Get the type of a Perl object from an RS-Perl reference}
\description{
 Given a Perl foreign reference in R, 
this acesses the Perl object to which it refers
and computes what type this is.
The types are 
 intege, number (double), string, reference,
array, hash, code, glob, file handle, 
}
\usage{
.PerlType(ref, pkg=NULL, perl=NULL)
}
\arguments{
  \item{ref}{either the Perl foreign reference whose value's 
is being queried or the name of a Perl variable
given as a string.}
 \item{pkg}{the name of the package in which to find
 a Perl variable specified by a string value for \code{ref}.
 (If \code{ref} is a \code{PerlReference} object, this argument is ignored.)}
 \item{perl}{the Perl interpreter to use when resolving
 the reference. Currently this is ignored, but it will
be honored in later releases.}
}
\value{
 A character vector identifying the type.
 If the object is a basic Perl type 
(i.e. scalar, array, hashtable), the vector has a single
element which gives the name of the type.
If the object is a Perl ``reference'' or a ``glob''
object, a second element gives the type of the object
to which it refers.
The possible types are:
hash, array, integer, string, double, glob, code,
IOhandle, reference.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}
\note{The names of the types will become more formal
and in-line with uses elsewhere.}

\seealso{
 \code{\link{.PerlReferenceObjects}}
}

\examples{
  a <- .PerlNewArray()
  .PerlType(a) # returns "array"

  if(.PerlExists("Join")) {
    pc <- .PerlGetCode("Join")
    .PerlType(pc)  # returns "code"
  }

    # Use the name of a Perl variable/symbol directly.
  if(!.PerlExists("Join")) 
    .PerlFile(system.file("examples", "RInit.pl", package= "RSPerl"))

  .PerlType("Join") # "glob"

    # Find a symbol that isn't a code value.
    # This is a IOhandle.
   .PerlType("STDIN")

\dontrun{
    # Find a symbol in another package.
  try({
    .PerlPackage("Net::FTP")
    .PerlType("login",pkg="Net::FTP")
  })
}

}
\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
\concept{marshall}
