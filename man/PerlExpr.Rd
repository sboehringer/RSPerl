\name{.PerlExpr}
\alias{.PerlExpr}
\title{Evaluate a Perl expression in string form}
\description{
 This is used to execute one or more Perl commands
given to the Perl interpreter in the form of a string. 
}
\usage{
.PerlExpr(expr, .convert = TRUE, .perl=NULL)
}
\arguments{
  \item{expr}{the string containing the
    Perl expression(s) to be evaluated.}
  \item{.convert}{determines whether the result of evaluating the Perl
    command is converted to a regular R object or left as a reference to
    the Perl value.

    This can also identify how the conversion is done, by specifying a
    native routine as the converter. See
    the example in \code{\link{.PerlGetCode}}
    for more details.
   }
  \item{.perl}{identifies which Perl interpreter to use
to evaluate the string. Not currently used.}
}
\details{
 Any assignments made in the expressions will
persist after the evaluation of the evaluation
unless explicitly undefined.
}
\value{
 The result of the Perl expression, converted
to R as usual (i.e. by value for primitives or references
for complex objects.)
}
\references{\url{http://www.omegahat.org}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{.Perl}}
\code{\link{.PerlFile}}
}

\examples{
 .PerlExpr("use R;", .convert = FALSE)

  # Define a new variable.
 .PerlExpr("@a = (1,2,3);", FALSE)
 .PerlExists("a", type="AV")

  # Define a Per sub-routine (function)
 .PerlExpr("sub foo { return($#_); }", .convert = FALSE)
 .Perl("foo", 1, 2.3, 4.5)

  # define a sub-routine that calls back to R.
 .PerlExpr("sub foo { R::objects(); }", .convert = FALSE)
 .Perl("foo")


}

\concept{Perl}
\keyword{interface}
