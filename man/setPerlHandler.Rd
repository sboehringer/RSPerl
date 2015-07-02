\name{setPerlHandler}
\alias{setPerlHandler}
\alias{getPerlHandler}
\title{Access the Perl Foreign Reference Manager}
\description{
These functions allow one to set or 
retrieve the current setting of the
R foreign reference  manager.
The manager is a collection of functions
that share state and handle 
adding, removing and resolving values
that are exported to Perl.
}
\usage{
setPerlHandler(handler=referenceHandlerGenerator())
getPerlHandler()
}
\arguments{
  \item{handler}{
   a list of functions (currently in a specific order)
   that provide the basic methods for managing
   (storing, resolving, removing) R reference objects
   exported to Perl.
  }
}
\details{
  The handler is typically a closure that shares
 the table of exported objects/values in a central
 table and allocates a unique name for each 
}
\value{
 \code{setPerlHandler} returns the previous 
handler instance. 
 \code{getPerlHandler} returns the current list
of functions.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}


\examples{
  setPerlHandler()

  getPerlHandler()
}
\concept{Perl}
\concept{Inter-system interface}
\keyword{interface}

