# Must install RSPerl with support for dynamically loaded POSIX module
# e.g.,
#   R CMD INSTALL --configure-args='--with-modules=POSIX' ~/RSPerl_0.8-0.tar.gz
#
library(RSPerl)
.PerlExpr("use POSIX;")
