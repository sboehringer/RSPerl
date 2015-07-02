#!/usr/bin/perl
use strict;
use R;
use RReferences;

R::initR("--silent");

R::eval("mkfunc <<- function(){ function() { 1 } }");

my $z1 = R::mkfunc();
my $z2 = R::mkfunc();
my $zz = R::call($z1);
print "zz ", $zz, "\n";



