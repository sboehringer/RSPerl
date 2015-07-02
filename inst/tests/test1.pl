use R;
use RReferences;

&R::initR("--silent");
&R::library("RSPerl");
&R::eval("par(mfrow=c(1,2))");
@x = &R::call("rnorm", 10);
# We need to make the @x a reference or the contents
# will be treated as individual arguments.
#&R::call("plot", \@x);

#&R::callWithNames("plot", {'x' , \@x,  'ylab','data'});
&R::callWithNames("plot", {'x' => \@x,  'ylab' => 'data'});

@x = &R::call("seq", 1,10);
&R::call("plot", \@x);

print "Sleeping for 5 seconds and then quitting\n";
sleep(5);


