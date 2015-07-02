use R;
use RReferences;


&R::initR();
print "Loading perl library\n";

&R::library("RSPerl");

# .PerlInit is currently called in the library(RSPerl)
#&R::call(".PerlInit") ;



@x = (1, 2, 3);
@y = (120, 119, 122);

&R::eval("print(search())");

$test = &R::callWithNames("wilcox.test", {'x',\@x, 'y',\@y, 
                                           'alt', 'greater', 
                                           'paired',1});

print "p-value ", $test->getEl("p.value"), "\n";


