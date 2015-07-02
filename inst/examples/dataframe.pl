use R;
use RReferences;

&R::initR("--vanilla");
&R::library("RSPerl");

my @x = &R::rnorm(10);
 print join(', ', @x), "\n";

R::data("mtcars");
$x = R::get("mtcars");
print join(', ', R::names($x)), "\n";

# This doesn't do what we want - still a reference.
$z =  R::as.list(R::get("mtcars"));
print $z, "\n";


@x = R::call("[[", $x, 1);
@y = R::call("[[", $x, 2);

print join(', ', @x), "\n";
print join(', ', @y), "\n";

