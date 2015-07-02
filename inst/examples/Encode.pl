use Encode;

# Encode::Supported();

@x = Encode::encodings();
print join(', ', @x), "\n";

# In R, use
# library(RSPerl)
# .PerlExpr("use Encode;")
# z = .Perl("Encode::encodings")
