\name{addConverter}
\alias{addConverter}
\alias{removeConverter}

\title{Manage the User-converter lists.}
\description{
  These functions allow one to add and remove a
  converter object to and from the list of
  user-defined converters that are used
  to convert an S object to a Perl object
  and vice-versa when an object is transferred
  across the boundary between the two systems.
}
\usage{
addConverter(match, converter, fromPerl=TRUE, class=NULL, description=NULL, autoArray=TRUE)
removeConverter(id, fromPerl = TRUE)
}
%- maybe also `usage' for other objects documented here.
\arguments{
  \item{match}{a function that takes a single argument, a
    reference to the underlying object being converted.
    Currently, this is a reference to a Perl object
    since the conversion works from Perl to R.}
  \item{converter}{the function that does the actual conversion. This
    gets called with one argument, the reference to the Perl object. }
  \item{fromPerl}{identifies which of the two lists to which the operation
    will be applied, specifically the converters from R to Perl (\code{FALSE}) or
    from Perl to R (\code{TRUE}).
   At present, only the "from Perl to R" direction is supported.}
 \item{class}{if given, takes the place of the \code{match}
   object and a simple match function is used that checks whether the
   Perl object is derived from the class identified by this name.}
  \item{description}{a human readable string that describes the converter}
  \item{autoArray}{currently ignored.}
  \item{id}{the index of the converter element in the list to remove.
  This starts at 1. (Better check!)}
}
\details{

}
\value{
 The index in the converter list into which this converter put.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}



\seealso{
  \code{\link{.Perl}}
  \code{\link{.PerlNew}}
  \code{\link{.PerlExpr}}
}

\examples{

}
\keyword{interface}
