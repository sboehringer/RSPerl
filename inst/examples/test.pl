# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use R;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use RReferences;

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

&R::initR("--silent");
&R::setDebug(0);

&R::library("RSPerl");
print "Loaded RSPerl library\n";

@x = R::eval("objects(2)");
print "objects @x\n";

print "Testing search path\n";
@x = R::call("search");
print "Search path: @x\n";

@x = &R::rnorm(5);
print "@x\n";
print $#x == 4 ? "ok1" : "not ok 1", "\n";

@x = &R::call("rnorm",5);
print "@x\n";
print $#x == 4 ? "ok2" : "not ok 1", "\n";


print "Testing objects(3)\n";
@x =&R::call("objects", 3);
print "# of objects = $#x\n";
print "element $#x/2 = $x[$#x/2]\n";

@x =&R::call("objects", "package:base");
print "# of objects = $#x\n";
print "element $#x/2 = $x[$#x/2]\n";


print "Testing plot(x,y); title(...)\n";
@x = 1..20;
@y = 21..40;

print "Lengths: $#x, $#y\n";


### $ok = &R::call("source", "check.S");
$ok = &R::eval('source(system.file("examples","check.S", package="RSPerl")); TRUE');

# Pass as references individual objects 
# rather than listing the entire contents on the
# stack 
# i.e. a difference in call of myCheck(x,y)
# or myCheck(x[1],x[2],...x[20],y[1],...,y[20])
$ok = &R::call("myCheck", \@x, \@y);
print "lengths are the same: $ok\n";


print "calling plot\n";
@z = &R::call("plot", \@x, \@y);
print "calling title\n";
&R::call("title","This is a title\n");
@x =&R::call("dev.off");



print "Testing dual call\n";
@x = &R::call("rnorm", 10);
#print "@x\n";
&R::call("postscript","duncan.ps");
&R::call("plot", \@x);
@x =&R::call("dev.off");


print "Testing call with named arguments\n";
%args = ('pch',"+", 'id', 100);
print "# of arguments: $#args\n";
$x = &R::callWithNames("foo", \%args);
print "Result: $x\n";

# R::call("plot", 1..20)
# R::call("plot", R::rnorm(20));
# R::call("plot", R::call("rnorm", 1..20))

