\name{parseEval}
\alias{parseEval}
\title{Parse and Evaluate an S command}
\description{
Parse and evaluate an S command 
and return the result.
This is a convenience function used 
by C code to call a single function
to do the parsing and evaluation of an expression.
}
\usage{
parseEval(cmd)
}
\arguments{
  \item{cmd}{a string (character vector of length 1) giving the S command
 to parse and evaluate.}
}
\details{

}
\value{
 The result of evaluating the S command.
}


\references{\url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\examples{
 parseEval("1:10")
 parseEval("plot(rnorm(10)); abline(h=5); TRUE")
}
\keyword{interface}
