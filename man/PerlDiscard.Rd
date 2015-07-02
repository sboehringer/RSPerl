\name{.PerlDiscard}
\alias{.PerlDiscard}
\title{Discards an internal Perl foreign reference}
\description{
  This is no longer needed (version 0.90) as we are using automatic garbage
  collection via external references rather than managing the
  references in an R environment.  This breaks the ability to use
  the package with S-Plus as is, but it is still possible to do it with
  a little work.
  
 This removes the entry in the internal
foreign reference table of Perl objects
that are exported to R. This is called
when one no longer has a need for 
an object resulting from a previous call to Perl
and want to reclaim the memory it is occupying.
}
\usage{
.PerlDiscard(obj, asVariable = TRUE, .perl=NULL)
}
\arguments{
  \item{obj}{the reference object that identifies the entry
in the Perl foreign reference table.}
  \item{asVariable}{current ignored, but related to whether 
the name should be treated as a Perl variable also.
}
  \item{.perl}{the Perl interpreter to use when 
resolving the reference.}
}
\details{
 This accesses the hash table that is used to store all
Perl objects that are returned to R.
}
\value{
 A logical value indicating whether the 
entry corresponding to the reference was removed from the
Perl foreign reference table or not.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}
\seealso{ 
\code{\link{.PerlReferenceObjects}}
\code{\link{.PerlReferenceCount}}
\code{\link{.PerlUndef}}
}

\examples{

\dontrun{
  .PerlExpr("@duncan = (1,2,3);")
  a <- .PerlGetArray("duncan", FALSE)
    ...
    # now release the array object from the 
    # export table.
#  .PerlDiscard(a)
}
}
\concept{Perl}
\keyword{interface}
