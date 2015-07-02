use Bio::DB::GenBank;

my $g = Bio::DB::GenBank->new();
my $s = $g->get_Seq_by_id('MUSIGHBA1');

my $gb = new Bio::DB::GenBank(-retrievaltype => 'tempfile' , 
			       -format => 'Fasta');



my $seqio = $gb->get_Stream_by_acc(['AC013798', 'AC021953'] );

print $gb, "\n";


