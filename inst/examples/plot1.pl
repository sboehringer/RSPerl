use R;
use RReferences;

@xdata=(1,2,3,4);
@ydata=(2,3,6,7);

 R::initR("--vanilla");
 R::x11();
 R::plot(\@xdata,\@ydata);
 sleep(10);
