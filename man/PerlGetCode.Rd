\name{.PerlGetCode}
\alias{.PerlGetCode}
\title{Gets a reference to a Perl subroutine or method}
\description{
 This resolves the \code{name} of the Perl subroutine or
 method within the specified Perl module (i.e. namespace)
 and returns a reference to it.
 This can then be used in future \code{.Perl} calls
 and apply-like operations.
 This is most useful for anonymous functions.
}
\usage{
.PerlGetCode(name, pkg = character(0), .perl = NULL, asFunction = FALSE)
}
\arguments{
  \item{name}{the name (a string) of the  Perl subroutine or method within a Perl
class/package}
  \item{pkg}{the name (a string) of the Perl package in which to locate
\code{name}. By default, this is the top-level Perl module  \code{main}.}
  \item{.perl}{a reference to the Perl interpreter to use
when resolving the symbol. This need only be specified when one has
created multiple concurrent Perl interpreters.}
 \item{asFunction}{a logical value, indicating whether to create an R 
  function that allows the Perl routine to be called directly
 from R. This is merely a convenient form of syntactic sugar.}
}
\details{
 This uses the \code{perl_get_cv()} C routine.
}
\value{
 An object of class \code{PerlCodeReference}
which extends \code{PerlReference}.
  \item{id}{ the unique name by which the value associated with this reference
can be resolved.}
  \item{table}{currently not used, but allows the use of multiple internal tables
for storing Perl references.}
  \item{pid}{the identifier of the process in which the reference was created
and hence the Perl session so that objects created in one session
used in another are identified and signalled as an error.}
  \item{class}{the class name of the Perl reference.}
  ...
}
\references{\url{http://www.omegahat.org}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{.PerlGet}}
\code{\link{.PerlGetArray}}
\code{\link{.PerlGetTable}}
}

\examples{

   # Load the file RInit.pl to get the Join function.
 .PerlFile(system.file("examples", "RInit.pl", package= "RSPerl"))

 pc <- .PerlGetCode("testHash")
 .Perl(pc, convert = getNativeSymbolInfo("fromPerlHV", PACKAGE = "RSPerl")$address)

 pc <- .PerlGetCode("Join")
 data(state)
# This does not work
# .Perl(pc, "::", state.name)
# but these do:
  .Perl(pc, .args = append("::", as.list(state.name)))

  .Perl(pc, "::", state.name[1], state.name[2], state.name[3])

 x = .PerlExpr("sub { return($#_);}")
    # should return 2, i.e. 3 arguments - 1
 .Perl(x, "a", "b", "c")

 .PerlExpr("sub foo { return($#_);}")
 .Perl("foo", 1, 2, 3)
}
\concept{Perl}
\keyword{interface}
