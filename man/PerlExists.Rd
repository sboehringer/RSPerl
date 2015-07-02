\name{.PerlExists}
\alias{.PerlExists}
\title{Tests whether a Perl object exists with a given name}
\description{
 This is used to test whether a particular variable,
sub-routine or method is currently defined in the Perl 
environment/session.
This can be used to determine if a variable has been
initialized previously and still exists.
}
\usage{
.PerlExists(name, pkg=NULL, type="SV")
}
\arguments{
  \item{name}{the name of the variable, sub-routine or method
that is being queried.}
  \item{pkg}{the name of a Perl package in which to attempt to find
 \code{name}. This effectively defaults to the top-level Perl module \code{main}.}
  \item{type}{The type of object being searched, influencing
how we actually find the object.}
}
\value{
 A single logical value indicating whether there
is a value bound to the specified name and
with the specified type.
}

\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}
\seealso{
\code{\link{.PerlGetArray}},
\code{\link{.PerlGetTable}},
\code{\link{.PerlGet}},
\code{\link{.PerlGetCode}}
}
\examples{
  # define a sub-routine RSSubstitute() if it doesn't already exist.
 if(.PerlExists("RSsubstitute", type = "CV")) {
   tmp <- "sub RSsubstitute { my ($tmp, $pat, $with) = @_; $tmp =~ s/$pat/$with/g; return $tmp;}"
   .PerlExpr(tmp)
 }

  # 
 if(.PerlExists("WithinR")) {
   .PerlAssign("WithinR", TRUE)
 }
  

}
\concept{Perl}
\keyword{interface}
