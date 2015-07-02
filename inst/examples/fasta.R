# To get BioPerl installed, use Perl 5.8.8
# to avoid any issues with AnyDBM_File and NDBM_File.
# Then install  IO-Stringy
#  HTML-Parser-3.54
#  IO-String-1.08
#  IO-stringy-2.110

# Also load libwww-perl for Bio::DB::GenBank

# Don't think we need
#    Scalar-List-Utils-1.14


# setenv PERL_MODULES "IO Fcntl Socket Storable XML::Parser::Expat DB_File File::Glob GDBM_File SDBM_File POSIX"

library(RSPerl)
.PerlExpr("use Bio::DB::Fasta;")

db = .PerlNew("Bio::DB::Fasta", "test.fa")


seqstring = db->seq(id)       # get a sequence as string
seqobj = db$get_Seq_by_id(id) # get a PrimarySeq obj
desc = db$header(id)          # get the header, or description line
