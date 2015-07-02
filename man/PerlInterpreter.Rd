\name{.PerlInterpreter}
\alias{.PerlInterpreter}
\title{Retrieve a reference to the current Perl interpreter(s)}
\description{
 This returns a reference to the current Perl interpreter
or, alternatively, returns a lists all of those that
have been created and still exist within this R session.
}
\usage{
.PerlInterpreter(all = FALSE)
}
\arguments{
  \item{all}{a logical value indicating whether
 identifiers for all the interpreters should be returned
(TRUE) or  just the currently active one.}
}
\details{
 A list of all the Perl interpreters
 explicitly created within the R/S session  
 is maintained internally. 
}
\value{
  An object of class \code{PerlInterpreter}
 with the following components:
  \item{id}{the value indicating how many interpreters
had been created before this one. This is a unique identified
within an R session.}
  \item{pid}{The R process identifier so that one can check
whether a serialized interpreter reference (i.e. saved to .RData)
should be used in a different session.}
}
\references{\url{http://www.omegahat.org}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{.PerlInit}}
\code{\link{.PerlTerminate}}
\code{\link{.Perl}}
\code{\link{.PerlExpr}}
\code{\link{.PerlFile}}
}

\examples{
    # Get the current interpreter.
  .PerlInterpreter()

   # Get the first interpreter.
  .PerlInterpreter(all = TRUE)[[1]]

    # Start a new one
\dontrun{
  .PerlInit()
  .PerlTerminate()
}
}
\concept{Perl}
\keyword{interface}
