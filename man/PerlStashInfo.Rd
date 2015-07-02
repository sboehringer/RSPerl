\name{.PerlStashInfo}
\alias{.PerlStashInfo}
\alias{.PerlObjects}
\title{Information about the elements of Perl module}
\description{
  \code{.PerlObjects} returns the names of the elements
  or global variables that are exported or accessible from
  a particular Perl module.
  \code{.PerlStashInfo} returns references to the objects
  themselves in a named list.
  Stash stands for symbol table hash, or an associative array
  or hash table that contains Perl symbols used by the language
  rather than simple key-value pairs.
}
\usage{
.PerlStashInfo(pkg="main", .convert = TRUE, .perl=NULL, .load = TRUE)
.PerlObjects(pkg="main", .perl=NULL)
}
\arguments{
  \item{pkg}{a string giving the name of the Perl module to query}
  \item{.convert}{a logical value indicating whether
the result table should be converted to an R named list
or left for use in Perl and returned as a Perl foreign reference.}
  \item{.perl}{an object identifying the Perl interpreter to use
    when resolving the package.}
  \item{.load}{a logical value indicating whether the Perl module should
    be loaded if it has not already been.  This is important to avoid
    infinite recursion for loading the \code{B::Stash} module which is
    used to determine if a module has already been loaded, including
    itself.
    However, this argument is more generally useful to avoid loading the
    module  if it has not already been so.
  }
}
\value{
 \code{.PerlObjects} returns a character vector
containing the names of the entries in the Perl module/package. \\
 \code{.PerlStashInfo} returns a list whose elements
are the Perl objects converted to R values, and so typically
\code{PerlReference} objects. These provide information about
what type the Perl object actually is.
}
\references{\url{http://www.perl.org}, \url{http://www.omegahat.org/RSPerl}}
\author{Duncan Temple Lang}

\seealso{
  \code{\link{.PerlPackage}}
  \code{\link{.PerlDiscard}}  
}

\examples{

   # like objects() but in Perl
 x <-.PerlStashInfo()

 x <- .PerlObjects()
 print(x)

\dontrun{
   # load the NNTPClient package
 try({
   .PerlPackage("News::NNTPClient")
      # now get the names of all its entries
   names(.PerlStashInfo("News::NNTPClient"))
   .PerlObjects("News::NNTPClient")
    x <- .PerlStashInfo("News::NNTPClient")
  })
}
}
\keyword{programming}
\concept{Perl}
\concept{Inter-system Interface}