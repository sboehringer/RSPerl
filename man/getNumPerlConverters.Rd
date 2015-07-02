\name{getNumPerlConverters}
\alias{getNumPerlConverters}
\alias{getPerlConverterDescriptions}
\title{Query the currently registered object converters between R and Perl.}
\description{
 These functions allow the user to examine what C routines
and R and Perl functions are currently registered
to implement the conversion between R and Perl objects.
These control how values in one system are converted
to objects in the other system as they are transferred
as arguments to functions in the foreign system
and returned as results to the calling system.
These functions give both the number 
and descriptions of each of the converters registered
in either direction (i.e., from R to Perl and vice-versa.)
The descriptions are usually specified by the registrant when the converters are
registered.
}
\usage{
getNumPerlConverters(which=c(fromPerl = FALSE, toPerl = TRUE))
getPerlConverterDescriptions(which=c(fromPerl = FALSE, toPerl = TRUE))
}
\arguments{
  \item{which}{the direction(s) of the conversion of interest, i.e. 
 from Perl to R and/or from R to Perl}
}
\details{
 Converters are registered at the C level as pairs
of C routines given by a matching routine that determines
whether the converter is appropriate for the object to be converted
and the  converter routine itself which performs the translation from one
system to the other. Additionally, 
}
\value{
 \code{getNumPerlConverters} returns an integer vector
giving the number of converters in the list for each of
the specified directions.
 \code{getPerlConverterDescriptions} returns a list
with an element for each of the directions specified.
Each element in this list is a character vector 
containing the description string for each of the 
different (match, converter) pairs.
}
\references{\url{http://www.omegahat.org/RSPerl},
\url{http://www.python.org}}
\author{Duncan Temple Lang}

\seealso{
\code{\link{.Perl}}
\code{\link{.PerlNew}}
}

\examples{
}
\keyword{programming}
\concept{Inter-system interface}
\concept{Perl}
\concept{marshall}

