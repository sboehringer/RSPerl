\name{.PerlReferenceObjects}
\alias{.PerlReferenceObjects}
\alias{.PerlReferenceCount}
\title{Query the internal table of stored Perl objects}
\description{
 These functions allow the user to query the  list of
foreign reference objects currently being maintained by the Perl reference manager.  
}
\usage{
.PerlReferenceObjects(which = NULL)
.PerlReferenceCount()
}
\arguments{
 \item{which}{currently ignored.}
}
\details{
 When the R/S engine attempts to return a non-primitive Perl object
to the R/S calling function or expression, it does so 
by storing the Perl object in an internal table and returning
a reference to that object. 
The \code{.PerlReferenceCount} provides information
about how many of these objects are currently being
stored and the total number that have been in the 
internal table throught the entire session.
\code{.PerReferenceObjects}
returns R/S objects which are references
for each of the objects currently held in the pool.
}
\value{
 \code{.PerlReferenceCount} returns
an named integer vector of length 2. 
  \item{current}{the number of objects \textit{currently} in the internal table.}
  \item{total}{the cumulated number of objects that have been in the internal table throught the R session.}

 \code{.PerlReferenceObjects} returns a list
with as many elements as there are elements in the internal
table. Each element is a \code{PerlReference} object
with the appropriate sub-class (e.g. \code{PerlArrayReference},
\code{PerlHashReference}, \dots).
}
\references{\url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{.PerlDiscard}}
}

\examples{
  .PerlObjects()
}
\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
\concept{marshall}
