=head1 DESCRIPTION

 Checks whether calling an R function or evaluating an R expression
 without assigning the return value avoids the conversion of the 
 the return value from R to Perl. This avoids unecessary computation
 and also the need to free references to unused values.

 We could explicitly test that no reference was created by 
 asking the R reference manager for the count of the number
 of references it handles.
  
=cut
use R;
use RReferences;

R::initR();
R::library("RSPerl");

print "Calling get and ignoring return value.\n";
# $o = R::eval("getPerlHandler()$total()");
R::call("get", "exists");
# $n = R::eval("getPerlHandler()$total()");
#print $o, " -> " , $n, "\n";

print "Now getting the value.\n";
$x = R::call("get", "exists");
print ref($x),"\n";


print "Calling with named arguments in void context\n";
R::callWithNames("get", { '' => 'exists', 'mode'=> 'function'});

print "Calling eval in void context\n";
R::eval("get('exists')");
