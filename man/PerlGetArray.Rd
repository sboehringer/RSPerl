\name{.PerlGet}
\alias{.PerlGet}
\alias{.PerlGetArray}
\alias{.PerlGetTable}
\alias{.PerlGet.default}
\alias{.PerlGet.PerlHashReference}
\alias{.PerlGet.PerlArrayReference}
\title{ Retrieve a Perl object.}
\description{

}
\usage{
.PerlGet(what, .convert = TRUE, .perl = NULL, ...)
.PerlGet.PerlArrayReference(what, .convert = TRUE, .perl = NULL,
          ..., apply = NULL)
.PerlGet.default(what, .convert = TRUE, .perl=NULL, ..., isArray = FALSE,
                   pkg=NULL, .sig=character(0))
}
%           isArray = FALSE, pkg = NULL, .sig = character(0)
\arguments{
  \item{what}{an identifier for a Perl object which can be either
the name of a Perl variable
(used in conjunction with the \code{pkg})
or, alternatively,  a \code{PerlReference} object.}
  \item{isArray}{a logical value indicating whether the Perl object is
to be treated (and coerced) to an array or not.}
  \item{.sig}{will allow in the future for controlling the conversion
to an R object from the Perl value by specifying either or both of the
Perl class and the R clas.}
  \item{pkg}{the name of the Perl package (or namespace) in which to find 
the variable named \code{what}. This is applicable only if 
\code{what} is a string, and not a \code{PerlReference} object.}
  \item{.perl}{the interpreter reference with which to
    resolve the name or reference.}
  \item{.convert}{a value indicating whether to convert the Perl object
    to a regular R object or a reference to a Perl value.
    This can be a logical value with \code{TRUE} indicating  to perform
    the conversion, if possible, or \code{FALSE} to leave it as a
    reference without attempting a conversion.
    It can also be the address of a native routine (see
    \code{\link[base]{getNativeSymbolInfo}})
    which will perform the conversion.
  }
  \item{apply}{}
  \item{\dots}{additional parameters for the different specific methods}
}
\details{
 This looks for a named variable by querying the Perl
stash (symbol table hash) for that package, defaulting to "main".
If \code{what} is a \code{PerlReference}, the
value is resolved by looking in the internal, local
reference cache. (See \code{.PerlReferenceObjects}.
Then an attempt to convert the Perl object to 
an R object is made. If no converter is available,
a reference to an object in this internal reference table is returned.
}
\value{
 The value of the Perl object returned as an R object,
the form of which is determined dynamically.
}
\references{\url{http://www.omegahat.org}}
\author{Duncan Temple Lang}
\seealso{ 
\code{\link{.PerlGetArray}}
\code{\link{.PerlGetCode}}
\code{\link{.PerlGetTable}}
}

\examples{
   # The directories in the Perl search path.
  .PerlGetArray("INC")
  .PerlGet("INC", isArray = TRUE)

   # The environment variables
  .PerlGetTable("ENV")

  .PerlExpr("@a = (1,2,3);")
  .PerlGet("a", isArray = TRUE)

  b <- .PerlNewArray()
  b[1] <- 2
  b[2] <- 1
  .PerlGet(b)


  .PerlExpr("@a = (1,2,3);")
  .PerlGet("a", TRUE)

  .PerlExpr("\%b = ('a',1,'b',2,'c',3);"); 
  .PerlGetTable("b")

   # Example of specifying a routine as a converter.
  sym = getNativeSymbolInfo("fromPerlHV", PACKAGE = "RSPerl")
  .PerlGetTable("ENV", .convert = sym$address)
}
\concept{Perl}
\keyword{interface}
