use R;
use RReferences;

# $x = &RReferences::new("Hi");
$x = new RReferences("Hi");
print "$x->{'name'}\n";
$y = $x->isa("RReferences");
print "$y\n";

# &R::setDebug(1);

&R::initR("--silent");
&R::library("RSPerl");
&R::eval("print(search()); T");
&R::eval("setPerlHandler(); T");
&R::eval("print(getPerlHandler()); T");

&R::eval("g <<- function() { list(a = 1, b=list(x=1, y = letters[1:3]), c=TRUE)}");
$x = &R::call("g");

print "$x\n";
print "$x->{'name'}\n";
$y = $x->isa("RReferences");
print "Is RReferences: $y\n";
$z = &R::call("length", $x);
# Should give 3, the length of the list returned by calling the 
# R function g().
print "Length: $z\n";
print "x: $x\n";
$a = $x->getEl('a');
print "a: $a\n";

$a = $x['a'];
print "a: $a\n";
