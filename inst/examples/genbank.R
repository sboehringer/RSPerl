dyn.load(system.file("libs", "RSPerl.so", package = "RSPerl"), local = FALSE)
library(RSPerl)


.PerlPackage("Bio::DB::GenBank")

gb = .PerlNew("Bio::DB::GenBank")

  # this returns a Seq object :
seq1 = gb$get_Seq_by_id('MUSIGHBA1')

seq1$length()
seq1$seq()
seq1$subseq(5, 20)
seq1$description()
seq1$display_id()

 # Bio::Species
sp = seq1$species()

getPerlClasses(sp)
getPerlMethods(sp)
names(getPerlMethods(sp, recursive = FALSE))

#
a = seq1$annotation()

names(a)
a[["_annotation"]]

# A list of the Bio::SeqFeature::Generic objects.
f = seq1$get_SeqFeatures()

  # this also returns a Seq object :
seq2 = gb$get_Seq_by_acc('AF303112');
class(seq2)

  # this returns a SeqIO object, which can be used to get a Seq object :
seqio = gb$get_Stream_by_id("J00522","AF303112","2981014")
seq3 = seqio$next_seq()


q = .PerlNew("Bio::DB::GenBank", '-retrievaltype' = 'tempfile', '-format' = 'Fasta')

seqio =gb$get_Stream_by_acc('AC013798', 'AC021953');

while( !is.null( clone <- seqio$next_seq()))  
     cat(clone[["display_id"]], "\n")
