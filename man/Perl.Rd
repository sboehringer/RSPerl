\name{.Perl}
\alias{.Perl}
\title{Invoke a Perl sub-routine or OOP method}
\description{
  This is used to call a sub-routine, either in the
main or top-level module or any other module, 
}
\usage{
.Perl(routine, ..., convert = TRUE, array = TRUE, pkg = NULL,
       ref = NULL, .sigs=character(), .args = list(...), .perl=NULL)
}
\arguments{
  \item{routine}{
 the name of the method or a reference to the Perl
object representing the method that is to be called.
The latter is a PerlCodeReference object
or a reference containing such an object
and is usually obtained by defining an anoymous routine
or by calling \code{\link{.PerlGetCode}}.
}
  \item{\dots}{arguments that are to be passed to the
Perl sub-routine or method being called,  having been
converted from R values to Perl values.}
  \item{convert}{logical value indicating whether 
the result is to be converted, if possible, or 
stored as a reference for future computations.}
  \item{array}{a logical value indicating whether the
result is to be treated as a scalar or array.
This is similar to \$a or \@a in the Perl language.
}
 \item{pkg}{the name of the package in which to find the subroutine
named \code{routine}. This only makes sense if \code{routine} is a string.}
  \item{ref}{if specified, identifies the object or name of the class
in which the OOP method should be found and subsequently called.
If the method is a static/class method, this should be the name
of the Perl class in the form of a string.}
  \item{.sigs}{Not yet used, but will allow one to control
how the arguments are converted. This is important when we export
R objects as foreign references.}
 \item{.args}{this allows the caller to specify the argument list
   directly, as in
   \code{.Perl("xxx", .args = as.list(c("a", "b", "c")))}}
  \item{.perl}{The identity of the perl interpreter to use
for this evaluation. This is only relevant if one uses multiple interpreters.}
}
\details{
This resolves the sub-routine or method
and arranges to convert the arguments to their corresponding Perl 
types and then invokes the code object (routine or method).
The result(s)  are then transferred back to R objects.
}
\value{
 A single value if \code{array} is \code{FALSE}
or, otherwise, a list of values.
Each value is either a simple scalar -- 
integer, numeric or string -- or an object reference
to a Perl object.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{.PerlExpr}},
\code{\link{.PerlFile}},
\code{\link{.PerlNew}},
\code{\link{.PerlGet}}
}

\examples{
 .PerlInit()
 .PerlFile(system.file("examples", "RInit.pl", package= "RSPerl"))
 .Perl("Join", "--", "ab","cd", "ef")
 .Perl("Sum", 1, 2, 3)

 # Note:  this does not work
 # .Perl(pc, "::", state.name)
 # but this does
  .Perl("Join", .args = append("::", as.list(state.name)))

 .PerlExpr("sub foo { return($#_);}")
      # should return 2, i.e. 3 arguments - 1
 .Perl("foo", 1, 2, 3)
}
\concept{Perl}
\keyword{interface}
