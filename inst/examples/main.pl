
my @k = keys(%main::);
print "# entries: ", $#k, "\n";
print join(', ', sort(keys(%main::))), "\n";


#use R;
#use RReferences;
require R;
require RReferences;

@k = keys(%main::);
print "# entries: ", $#k, "\n";
print join(', ', sort(keys(%main::))), "\n";
