use R;
use RReferences;

R::initR("--vanilla");
R::library("RSPerl");

@list = 1..15;
$obj = R::call("matrix", \@list, 3, 5);

$obj = getMatrix();

print $obj, "\n";

# $n = $obj->nrow();

$n = R::call("nrow", $obj);
print $n, "\n";

$n = R::call("[", $obj, 1, 2);
print $n, "\n";

sub getMatrix {

 my @list = 1..15;
 my $obj = R::call("matrix", \@list, 3, 5);
 return($obj);
}

