#!/usr/bin/perl -w

use strict 'vars';
require R;
require RReferences;
&R::startR( "--silent", "--vanilla" ); &R::library("RSPerl"); 
# &R::setDebug(100);
 
my @a;
push @a, \@{ [ split //, 'abc' ] };
push @a, \@{ [ split //, 'def' ] };
push @a, \@{ [ split //, 'ghi' ] };
push @a, \@{ [ split //, 'jkl' ] };
push @a, \@{ [ split //, 'ABCD' ] };
 

&R::eval( "f <<- function(x){ print(x) }" ); 

&R::call( "f", \@a);

