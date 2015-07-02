use R;

&R::initR("--silent");
$x = &R::call("sum", (1,2,3));
print "Sum = $x\n";


