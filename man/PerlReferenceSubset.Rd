\name{[.PerlArrayReference}
\alias{[.PerlArrayReference}
\alias{[<-.PerlArrayReference}
\alias{[.PerlHashReference}
\alias{[<-.PerlHashReference}
\title{Extract and assign elements of a Perl array or hashtable}
\description{
  These operators allow the R programmer
to use the familiar \code{[} and
\code{[<-} operations on Perl references
so that the Perl object is manipulated
and elements are extracted or assigned as if they were
local to R.
}
\usage{
\method{[}{PerlArrayReference}(obj, ..., drop = TRUE, convert = TRUE)
\method{[}{PerlArrayReference}(ref, ...) <- value
\method{[}{PerlHashReference}(obj, ..., drop = TRUE, convert = TRUE)
\method{[}{PerlHashReference}(ref, ...) <- value
}
\arguments{
  \item{obj}{
the Perl reference object of class
\code{PerlArrayReference} or
\code{PerlHashReference} which is to be subsetted
or into which elements are to be assigned.}
  \item{ref}{
the Perl reference object of class
\code{PerlArrayReference} or
\code{PerlHashReference} which is to be subsetted
or into which elements are to be assigned.}
  \item{\dots}{identifiers for the elements to be extracted
or assigned. These are numbers (integers or numerics) for
\code{PerlArrayReference} objects
and strings for \code{PerlArrayReference} objects.}
  \item{value}{the values to be assigned to the elements of the array or
  hash table}
\item{drop}{a logical, which if \code{TRUE},
  means that if there is only a single value identified in the subset,
  it is returned as-is rather than as a list of length 1 containing this
  object.}
\item{convert}{a logical value indicating whether the resulting Perl
  object should be converted to a regular R object (\code{TRUE})
  or returned as a reference to the Perl object (\code{FALSE}).}
}
\details{
 This call the corresponding
 C routines functions
 \code{RS_PerlArrayElement},
 \code{RS_PerlHashElement},
  \code{\link{.PerlSetArray}}
and
  \code{\link{.PerlSetHash}}
respectively.
}
\value{
 The subsetting operations return 
\code{list} objects containing the subsetted
elements.
The element-wise assignment operators
return the modified object.
}
\references{\url{http://www.omegahat.org}}
\author{Duncan Temple Lang}
\note{
While Perl uses indeces starting at $0$,
these operators work in the S style, where
the first element is indexed by $1$.
\\
Logical indexing does not work for these
subset and assignment operators.
}

\seealso{
 \code{\link{.PerlSetArray}}
 \code{\link{.PerlSetHash}}
}

\examples{
  a <- .PerlNewArray()
  a[1] <- "foo"
  a[2] <- "bar"
  a[1]
  a[2]

\dontrun{
.PerlFile(system.file("tests", "method.pl", package = "RSPerl"))
 o <- .PerlNew("Mine", 1, 2, 3)
 o[1]
 o[2]
 o[2] <- 100
 o[2]
}

\dontrun{
.PerlFile(system.file("tests", "class.pl", package = "RSPerl"))
 o <- .PerlNew("MyClass", "abc", 1)
 o["abc"]
 o["dummy"]
 o["xyz"] <- 10
 o["xyz"] 
}
}
\concept{Perl}
\keyword{interface}
