use R;
use RReferences;

&R::initR("--silent");

&R::library("RSPerl");

 @x = (1,2);
 &R::callWithNames("par", {'mfrow', \@x} );

 @x = 1..10;
 @y = &R::call("rnorm", 10);
 # &R::callWithNames("plot", {'',\@x, 'ylab', 'My values'});
 &R::callWithNames("plot", {'',\@x, '', \@y, 'ylab', 'My values'});
# &R::callWithNames("hist", {'', \@y, 'main', 'Normals', 'xlab', ""});
 &R::callWithNames("hist", {'', \@y, 'main', 'Normals', 'xlab', ""});

 sleep(3);
