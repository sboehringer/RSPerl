\name{.PerlClear}
\alias{.PerlClear}
\title{Remove all the elements of a Perl array or hash table.}
\description{
 This removes all of the elements within a Perl 
array or table. It does not remove the container,
just its contents.
}
\usage{
.PerlClear(ref)
}
\arguments{
  \item{ref}{ a string giving the name of a Perl variable
identifying a hash table/associative array,  or a
\code{PerlHashReference} or
\code{PerlArrayReference} object.}
}
\details{
 This calls the \code{hv_clear} or \code{av_clear}
routine depending on the type of the Perl object
identified by \code{ref}
}
\value{
 A logical value indicating whether the reference
was resolved to an array or table object.
}
\references{\url{http://www.omegahat.org}}
\author{Duncan Temple Lang}
\note{We may add an argument to allow th specification of a package name.
In the interim, one should use a \code{PerlReference} object.}
\seealso{
\code{\link{.PerlUndef}}
}

\examples{
  b <- .PerlNewTable(a=1,b=2,c=3)
 .PerlClear(b)
}
\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
\concept{marshall}