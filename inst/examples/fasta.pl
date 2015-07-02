use Bio::DB::Fasta;
use strict;

my $file = "test.fa";
my $db = Bio::DB::Fasta->new($file);  

print $db, "\n";

