use Bio::Species;

print "Loaded Species\n";

use B::Stash;
print join(', ', keys(%B::Stash::Seen)), "\n";

use Bio::SeqIO;
print join(', ', keys(%B::Stash::Seen)), "\n";

