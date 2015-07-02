
use R;

startR("--gui=NONE", "x", "y", "z");

@x = R::call("search");

print join(', ', @x), "\n";

