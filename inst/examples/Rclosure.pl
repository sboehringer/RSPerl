#!/usr/bin/perl
use strict;
use R;
use RReferences;

   

#
# FIXME:
#   This program reproduces the bug related to calling R closure
#   We suspect that this is related to stack management.
#   Placing a break point in R.c:121
#


R::initR("--silent");

# Change the environment here to ensure that it is nothing to do with that
R::eval("mkfunc <<- function() {   e =  function() { 1 } ; environment(e) = globalenv() ; e } ");

# But the following original version from Hong Ni illustrates the problem.
R::eval("mkfunc <<- function() {  function()  1 } ");

# Just to make certain it is anonymous functions.
R::eval("foo <<- function() { cat('foo\n'); 1  } ");

my $z = R::mkfunc();

my $zz = R::call($z);
print $zz, "\n";

for (1..3)
{
    my %foo;  # providing an initialization value removes the problem, i.e. () - not {}
    my $zz = R::call($z); #XX Put a \ here and uncover an unprotect error.
    my $zz = R::call("foo");
    print "Bug: ", scalar(keys %foo), "\n"; # if ($_ != 2);    # bug, there should be no keys in %foo
    %foo = (1..12);

}
