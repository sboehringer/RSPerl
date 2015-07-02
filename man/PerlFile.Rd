\name{.PerlFile}
\alias{.PerlFile}
\title{Parse and evaluate a Perl script from files.}
\description{
 This reads one or more files specified via \code{fileName} and parses
them. If \code{run} is \code{TRUE}, the resulting code is evaluated.
}
\usage{
.PerlFile(fileName, run = TRUE, extensions=character(0), .perl=NULL)
}
\arguments{
  \item{fileName}{
a character vector of command line arguments as they would be passed to Perl
containing one or more files (and also scripts, flags, etc.)}
  \item{run}{a logical value indicating whether the Perl code 
read from the files given via \code{fileName} should be evaluated or not.}
  \item{extensions}{an optional  string  identifying
 the name of a C routine which is to be used to load Perl modules
that require C code. See the overview.nw for a description of
the C routine and how to automatically generate it.
}
  \item{.perl}{ the interpreter to use for parsing and evaluating the scripts.}
}
\value{
 If the code is evaluated (i.e. \code{run} is \code{TRUE}),
 an integer value indicating the status of the evaluation is 
executed.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{.PerlExpr}}
\code{\link{.Perl}}
\code{\link{.PerlNew}}
}

\examples{

  .PerlFile(system.file("examples", "method.pl", package="RSPerl"))
  .PerlFile(system.file("examples", "RInit.pl", package="RSPerl"))

}
\keyword{interface}
\concept{Perl}
