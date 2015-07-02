\name{.PerlLength}
\alias{.PerlLength}
\title{The number of elements in a Perl array or hash table.}
\description{
 Determine the number of elements in a Perl 
array or hash table/associative array.
}
\usage{
.PerlLength(obj)
}
\arguments{
  \item{obj}{a string identifying Perl variable, or a
\code{PerlArrayReference} or \code{PerlHashReference}
reference object, either form identifying a 
Perl array or hash table.}
}

\value{
 An integer  indicating the number of elements
in the specified array or table.
Note that this is different from the 
value returned in a Perl script
via for an array or table \code{x} in the command
\code{$#x} which returns the index of the last element,
i.e. the number of elements $- 1$.
}
\references{\url{http://www.omegahat.org}}
\author{Duncan Temple Lang}

\seealso{
 \code{\link{.PerlNewArray}}
 \code{\link{.PerlNewTable}}
 \code{\link{.PerlClear}}
}

\examples{
  b <- .PerlNewTable(a=1,b=2,c=3)
 .PerlLength(b)

  a <- .PerlNewArray(1,2,3, 4, 5, 6, 7)
 .PerlLength(a)
}
\concept{Perl}
\keyword{interface}
