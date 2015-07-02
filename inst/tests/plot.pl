use R;
use RReferences;

&R::initR("--silent");
&R::library("RSPerl");

$z = &R::call("rnorm",1);
printf "rnorm: $z\n";

&R::call("x11");

@x=1..3;
&R::call("plot", \@x);
&R::call("plot", (1,2));
sleep(4);

