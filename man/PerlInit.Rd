\name{.PerlInit}
\alias{.PerlInit}
\title{Create and Initialize or Close  a Perl Interpreter}
\description{
\code{.PerlInit} creates a new Perl interpreter.
One can have multiple intepreters in existence at
any one time.
Currently, loading the \code{RSPerl}
package calls \code{.PerlInit}
to create a default interpreter. You will
only need to create another if you
want separate interpreters or if you want to
initialize an interpreter in a special manner.
}
\usage{
.PerlInit(args=perlInitArgs(), extensions=character(0),
           run = FALSE, verbose=FALSE,
           loadModules = c("R", "RReferences"))
}
\arguments{
  \item{args}{command line arguments as they would be specified
to a stand-alone Perl instance, including the argv[0] which
is usually given as R. This is normally computed
from the \code{\link{perlInitArgs}} function unless the caller
wants to override these values.}
  \item{extensions}{an optional  string  identifying
 the name of a C routine which is to be used to load Perl modules
that require C code. See the overview.nw for a description of
the C routine and how to automatically generate it.
}
  \item{run}{a logical value indicating whether the Perl code
read from scripts (via -e arguments) or files should be evaluated or not.
This is almost always \code{TRUE}.}
 \item{verbose}{logical value: if \code{TRUE}, numerous messages are printed
   during the initialization.}
 \item{loadModules}{ instructions to load specific Perl modules after
   the interpreter has been initialized. This is typically given as a
   character vector which is passed to \code{\link{.PerlPackage}}.
   To avoid loading any modules, pass the value \code{FALSE} for this argument.
 }
}
\details{
}
\value{
  A PerlInterpreter reference object identifying the particular Perl
  interpreter. This is an opaque data type that can only be used
  in subsequent calls to have any use.
  This can be passed to  \code{\link{.PerlTerminate}}
  to discard the newly created interpreter.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}


\seealso{ 
\code{\link{.PerlTerminate}}
}

\examples{
 .PerlInit()

   # append values on to the defaults
 .PerlInit(c(perlInitArgs(), "-e", "print 'Welcome to RS-Perl\n';"))

   # Load another module.

\dontrun{
   # NNTPClient may not be installed.
 .PerlInit(c(perlInitArgs(), "-MNews::NNTPClient"))
}

   # override the default initialization arguments, 
   # including specifying the first argument which is the
   # name of the program.
 .PerlInit(c(commandArgs()[1], system.file("examples", "RInit.pl", package="RSPerl")))


\dontrun{
  .PerlTerminate()

   # Also when a package that uses the Perl interface is unloaded
   # one might want an onUnload method to terminate that interpreter.
}
}
\concept{Perl}
\concept{Inter-system interface}
\keyword{interface}
