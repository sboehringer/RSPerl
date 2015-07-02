#!/usr/bin/perl -w

use R;
use RReferences;

&R::initR();

$x = R::data("mtcars");

print $x, "\n";

if(0) {
$f = R::call('as.formula', "mpg ~ cyl + hp + wt");
print $f, "\n";
$k = R::class($f);
print $k, "\n";
}

$myFit = R::lm(R::call('as.formula', "mpg ~ cyl + hp + wt"), R::get('mtcars'));

print "Perl's view: ", $myFit, "\n";
R::print($myFit);

print join(', ', R::coef($myFit)), "\n";

print join('? ', $myFit->coef()), "\n";




