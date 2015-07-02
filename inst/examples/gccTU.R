library(RSPerl)
.PerlExpr("use GCC::TranslationUnit;")
z = .Perl("GCC::TranslationUnit::Parser::readTU", "",
           "/home/duncan/Projects/org/omegahat/SLanguage/InterfaceGenerators/Gcc/Perl/examples/gtk.c.tu",
          convert = FALSE)

z$name()

z["chan"]

z$type()                #XXX
z$type(convert = FALSE) 



z = .Perl("GCC::TranslationUnit::Parser::parseTU",
           "",
           "/home/duncan/Projects/org/omegahat/SLanguage/InterfaceGenerators/Gcc/Perl/examples/gtk.c.tu",
          convert = FALSE)


n = z[2]
n["chan", convert = FALSE]
