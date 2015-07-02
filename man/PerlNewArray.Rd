\name{.PerlNewArray}
\alias{.PerlNewArray}
\alias{.PerlNewTable}
\title{Create a Perl array or table directly}
\description{
 This allows the caller to create a Perl array or table
programmatically from within R/S.
This is different from evaluating a Perl expression
which assigns an array to a variable.
This allows the array/table to be ``anonymous'', i.e. just
in memory and not bound to a Perl variable.
This avoids name conflicts.
}
\usage{
.PerlNewArray(..., name=NULL)
.PerlNewTable(..., name=NULL)
}
\arguments{
  \item{\dots}{the individual elements that are to be inserted
into the array (in ther order they are given to the S function).
In the case of \code{.PerlNewTable}, each of the \dots
arguments should have a name which is used as the key for that element.
}
  \item{name}{an optional character string which, if present,
causes the array to be assigned to a Perl variable with this name.}
}
\details{
 This creates the array internally and, if \code{name}
is not specified, it is stored in a local internal table
and a reference to it is returned. This allows the S programmer
to use the array in subsequent calls.
}
\value{
 If \code{name} is not specified, an object
of class \code{PerlArrayReference} is returned.
This identifies the internally stored object.
If \code{name} is specified, an object of class
\code{PerlVariable} is returned.
}
\references{\url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}
\seealso{
\code{\link{.PerlNewTable}}
\code{\link{.PerlNew}}
}
\examples{
 a <- .PerlNewArray()
 a[1] <- 10
 a[1]
   # Now throw it away and allow it to be garbage collected.

 .PerlDiscard(a)
}
\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
\concept{marshall}
