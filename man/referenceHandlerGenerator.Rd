\name{referenceHandlerGenerator}
\alias{referenceHandlerGenerator}
\title{Foreign Reference Handler}
\description{
Create an instance of the foreign reference
handler, which is a collection of functions
that share the same data to manage
how references to R objects
are created, resolved, removed, etc.
}
\usage{
referenceHandlerGenerator()
}
\details{
This is usually called just once and
then passed to C code to be stored
for the duration of the R session.
See \code{\link{setPerlHandler}}.
}
\value{
A list of functions (in the following order)
  \item{handler}{a function that processes method invocations on a reference.}
  \item{createReference}{create and optionally register a reference to an R object.}
  \item{addReference}{register a reference with the internal table.}
  \item{remove}{remove a reference from the table of exported references,
   making it eligible for garbage collection if no other reference to it exists.}
  \item{getReference}{resolve a reference}
  \item{references}{a list of all the active exported objects}
  \item{total}{the number of references that have been exported during this session.}
}
\references{\url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}
\seealso{
\code{\link{setPerlHandler}}
\code{\link{getPerlHandler}}
}

\examples{
 setPerlHandler(referenceHandlerGenerator())
}
\concept{Perl}
\concept{Inter-system interface}
\keyword{interface}