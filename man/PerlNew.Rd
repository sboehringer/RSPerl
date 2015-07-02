\name{.PerlNew}
\alias{.PerlNew}
\title{Create an instance of a Perl class.}
\description{
 This creates an instance of a specified Perl class
by calling its constructor with the arguments 
provided by the R user and returns a reference to this
object.
}
\usage{
.PerlNew(klass, ..., .convert = FALSE, .perl = NULL, .new = "new", .load = FALSE)
}
\arguments{
  \item{klass}{the name of the Perl class which is to be instantiated.}
  \item{\dots}{arguments to be passed to the constructor for this class.}
  \item{.convert}{a logical value indicating whether the usual converters
should be applied to the newly created
when returning its value. This is usually FALSE so that
the object is left in Perl. If a suitable converter exists and the value
of this parameter is TRUE, the object will immediately be converted.}
  \item{.perl}{the Perl interpreter to use when creating the new object.}
  \item{.new}{the name of the method in the Perl class to call to create the instance.}
  \item{.load}{a logical value indicating whether to attempt to load the
    Perl package identified by \code{klass} or not. If this is
    \code{TRUE}, a call to \code{\link{.PerlPackage}} is made 
    with the value of \code{klass} as its argument
    before instantiating the object.
  }
}
\value{
 Typically, a reference to a Perl object
of class \code{PerlReference}.
}
\references{\url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\note{
  If the package/class cannot be resolved by Perl,
  it can terminate the Perl and R session!
}
\seealso{
 \code{\link{.Perl}}
 \code{\link{.PerlFile}}
 \code{\link{.PerlExpr}}
}

\examples{
 .PerlFile(system.file("examples", "method.pl", package="RSPerl"))

 data(state)
 m <- .PerlNew("Mine",  .args = as.list(state.name))

 m$Display(0)
 m$Display(10)

}
\keyword{interface}
\concept{Perl}
