\name{PerlReference accessor}
\alias{$.PerlReference}
\title{Syntax for calling a Perl references's method}
\description{
 This is a mechanism that allows the S programmer
invoke a method in a remote Perl reference
in the form
  \code{ref$method(arg1, arg2, ....)}
rather than \code{.Perl(ref, "method", arg1, arg2, ...)}
}
\usage{
\method{$}{PerlReference}(obj, name)
}
\arguments{
  \item{obj}{the \code{PerlReference} object whose method is
to be called.}
  \item{name}{the name of the method to be called.}
}
\details{
 This does not call the Perl method, but instead
creates and returns a function that, when invoked,
calls the Perl method and passes its functions
to that Perl method call.
}
\value{
 A function that when invoked will evaluate
the call \code{.Perl(obj, name, ...)}.
The function is a closure that has access
to the \code{obj} and \code{name} values.
}
\references{\url{http://www.omegahat.org}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{.Perl}}
}

\examples{
  .PerlFile(system.file("examples", "method.pl", package="RSPerl"))
  a <- .PerlNew("Mine", "red", "green", "blue")
  a$Display(1)
}
\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
\concept{marshall}

