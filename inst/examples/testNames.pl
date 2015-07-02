use R;
use RReferences;


# Test for undefined argument in callWithNames. Thanks to Michael Dondrup.

&R::initR("--silent");

&R::library("RSPerl");

$x = &R::callWithNames("foo", {'x' => 1});

$x = &R::callWithNames("foo", {'x' => undef});

print "Second answer ", $x, "\n";
