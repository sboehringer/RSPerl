\name{perlInitArgs}
\alias{perlInitArgs}
\title{Returns command line arguments for initializing a Perl interpreter}
\description{
 This generates a character vector containing the minimal command 
line arguments that can be passed to a Perl instance
to get it started.
}
\usage{
perlInitArgs()
}
\details{
Note that this returns the string array (character vector)
as it is given to a C program when starting.
It contains not just the arguments the user
specifies
but also the \code{argv[0]} element
passed to it when called from C, in other words
the name of the program. This value is unimportant, but
necessary.
}
\value{
  A character vector.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\seealso{ 
\code{\link{.PerlInit}}
\code{\link{.PerlTerminate}}
}

\examples{
 .PerlInit(perlInitArgs())
}
\concept{Perl}
\concept{Inter-system interface}
\keyword{interface}
