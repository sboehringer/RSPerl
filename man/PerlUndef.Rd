\name{.PerlUndef}
\alias{.PerlUndef}
\title{Remove a Perl ``variable'' definition}
\description{
 This allows the caller to undefine or remove
a Perl variable or sub-routine from a
Perl module.
}
\usage{
.PerlUndef(name, scalar = FALSE, array = FALSE, table = FALSE,
            sub = FALSE, pkg = NULL, .perl = NULL)
}
\arguments{
  \item{name}{the name of the variable being removed}
  \item{scalar}{logical value indicating whether the variable
is a scalar. Probably not used.}
  \item{array}{logical value indicating whether the variable
is an array. Probably not used.}
  \item{table}{logical value indicating whether the variable
is a table. Probably not used.}
  \item{sub}{logical value indicating whether the variable
is a sub-routine or method. Probably not used.}
  \item{pkg}{the module in which the variable/sub-routine is defined.
This is useful to specify when we need to remove the entry 
directly from the module's own hash table.}
  \item{.perl}{the perl interpreter to use when resolving
the variable.}
}
\details{
 This looks in the module's hash table
(or glob) and removes the entry identified by
the \code{name} string.
}
\value{
 A logical value indicating if the variable
was found and removed successfully.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}
\note{The interface will change slightly but the effect will
be the same. We will simply remove the type arguments 
(\code{scalar}, \code{table}, \dots)
and access the module's hash table directly.
}


\seealso{
\code{\link{.PerlDiscard}}
}

\examples{
  .PerlExpr("@x = (1,2);")

  .PerlUndef("x")
}
\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
\concept{marshall}
