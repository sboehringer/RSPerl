\name{.PerlTerminate}
\alias{.PerlTerminate}
\title{Close and destroys a Perl Interpreter}
\description{
 This discards a Perl Interpreter and releases all of its resources,
including any variables defined in that ``session''.  This is useful
when one wants to reclaim memory used by Perl or simply clear an
entire Perl session and start a new one.
}
\usage{
.PerlTerminate(.perl = NULL)
}
\arguments{
  \item{.perl}{ an R \code{PerlInterpreterReference} object
identifying which of the existing interpreters should be destroyed.
Currently not used.}
}
\details{
 This looks up the list of interpreters
managed by the RS-Perl interface and
finds the one identified by the \code{.perl}
argument. Then it calls the necessary
C routines to release this interpreter.
}
\value{
 A logical value indicating whether
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\note{
  In one version of Perl (5.8.8) on one machine, closing an interpreter
  gave rise to numerous warning messages such as
  \code{Attempt to free non-existent shared string 'path_sep' during
    global destruction.}
  On the same machine with version 5.8.0, no such errors arose.
  I'll look into this further as  embedding in a simple, stand-alone
  application (perlEmbed.c in the distribution) causes no problems.
}
\seealso{\code{\link{.PerlInit}}}

\examples{
\dontrun{
 perl <- .PerlInit()

 .PerlTerminate(perl)
}
}
\concept{Perl}
\concept{Inter-system interface}
\keyword{interface}
