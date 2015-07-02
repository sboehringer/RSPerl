\name{names.PerlHashReference}
\alias{names.PerlHashReference}
\alias{.PerlNames}
\title{Get the keys of a Perl associative array.}
\description{
 This returns a character vector containing the keys
(or names) of the elements of a Perl associative
array or hash table.
}
\usage{
.PerlNames(hv)
names.PerlHashReference(x, ...)
}
\arguments{
  \item{x}{the name of a Perl variable or a \code{PerlHashReference}
object, each identifying a Perl associative array.}
  \item{hv}{the name of a Perl variable or a \code{PerlHashReference}
object, each identifying a Perl associative array.}
  \item{\dots}{unused, but present to math the generic \code{\link{names}}
arguments.}
}
\value{
 A character vector whose length is the number of entries
in the Perl associative array identified by \code{x}.
The elements of the vector are the keys of the Perl hash table.
}
\references{\url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\seealso{
 \code{\link{.PerlNewTable}}
 \code{\link{.PerlLength}}
 \code{\link{.PerlClear}}
}

\examples{
   # Create a new table.
 b <- .PerlNewTable(a=1,b=2,c=3)  
   # Get the names explicitly.
 .PerlNames(b)

   # Get the names using the PerlHashReference method for names().
 names(b)

   # Use a Perl variable, rather than a reference.
 .PerlExpr("\%b=('a', 1,'b', 2,'c', 3);")
   # Cannot use names as the name is a string, not a reference
   # and so names() won't call the correct method.
 .PerlNames("b")
}

\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
\concept{marshall}

