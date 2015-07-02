\name{foreignReference}
\alias{foreignReference}
\title{Create reference to exported R object}
\description{
This creates a reference to an R object
suitable for exporting it to Perl.
It wraps the specified value into
an \code{AnonymousRReference}
and optionally registers it
with the foreign reference manager.
}
\usage{
foreignReference(obj, id = NULL, className = NULL, targetClasses = NULL, register = TRUE)
}
\arguments{
  \item{obj}{the value to be exported.}
  \item{id}{an optional name to use for the reference, allowing the user
  to provide a fixed, known name rather than using an anonymous identifier.}
  \item{className}{the name of the class the reference is to be exported with.
  This is used to control the conversion from R to Perl.}
  \item{targetClasses}{the name of the class the reference is to be exported with.
  This is used to control the conversion from R to Perl.}
  \item{register}{ logical value indicating whether 
  we should also register the reference with the current foreign reference
  manager.}
}
\value{
A list with elements
\item{id}{the identifier for the reference}
\item{value}{the value which is being referenced by this
 proxy/reference object.}
\item{className}{the value of the argument
 \code{className}.}
\item{targetClasses}{the value of the
 \code{targetClasses} argument.}
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}


\seealso{
\code{\link{referenceHandlerGenerator}}
}

\examples{
}
\concept{Perl}
\concept{Inter-system interface}
\keyword{interface}

