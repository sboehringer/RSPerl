use R;
use RReferences;

R::initR();

open(IN, "data");

@x=();

while(<IN>) {
    $x[$#x + 1] = $_ + 0;
}

print "@x\n";
$z = R::call("sum", \@x);
print "$z\n";


@x = ("1", "2", "3");
print "@x\n";
$z = R::call("sum", R::call("as.numeric", \@x));
print "$z\n";
