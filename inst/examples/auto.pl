use R;

# This tests the AUTOLOAD feature of the R package in Perl.
# It will call the sum function directly from R::sum().

&R::initR("--silent");
$x = &R::sum(1,2,3);
print "Sum = $x\n";


