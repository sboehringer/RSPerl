\name{.PerlSetHash}
\alias{.PerlSetHash}
\alias{.PerlSetArray}
\title{Set elements of a Perl array or (hash) table}
\description{
 These functions allow one to set the values
of one more elements of a Perl array or table.
They underly the convenience methods
for assigning values to a 
\code{PerlArrayReference}
and \code{PerlHashReference}
of the form
\code{x[1] <- "a"}
and
\code{x["a"] <- 1}
}
\usage{
.PerlSetHash(ref, ..., value)
.PerlSetArray(ref, ..., value)
}
\arguments{
  \item{ref}{the Perl object reference which should be
a \code{PerlHashReference} or
\code{PerlArrayReference} for 
\code{.PerSetHash} and \code{.PerlSetArray}
respectively.}
  \item{\dots}{values identifiying 
the elements of the array (as integers)
or hash-table (as strings) for 
\code{.PerSetHash} and \code{.PerlSetArray}
respectively.
 }
  \item{value}{the value to be assigned to
the elements of the Perl array or table.}
}
\details{
This converts the values and the element
identifiers to Perl and resolves the Perl reference
there and then takes the appropriate action.
}
\value{
 The object \code{value} so that it can
used in linked assignments
of the form
 \code{x <- y <- .PerlSetHash(ref, 1, value="Foo")}
}
\references{\url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\seealso{
\code{.PerlGet}
\code{.PerlGetArray}
\code{.PerlGetHash}
}

\examples{
  # Manipulation of an array
 a <- .PerlNewArray()
 .PerlSetArray(a, 1, value="Test")
 .PerlGetArray(a)
 a[1]
 a[1] <- "Again"
 a[1]

 a[2] <- "Foo"

  # Manipulation of a Hash table.
 tb <- .PerlNewTable()
 .PerlSetHash(tb, "a", value="Test")
 .PerlSetHash(tb, "b", value="Again")
 .PerlGetTable(tb)
 tb["c"] <- "Another"
 tb["c"]
}
\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
\concept{marshall}
