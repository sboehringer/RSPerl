#!/usr/bin/perl -W

use IO::File;
use warnings ;
use IO::Uncompress::AnyUncompress qw(anyuncompress $AnyUncompressError) ;

my $file = "test.gz";
my $fh;

$fh = new IO::Uncompress::AnyUncompress $file
	    or die "Cannot get the uncompressed version";


my $z;
$z = $fh->getline();
print $z, "\n";
$z = <$fh>;
print $z, "\n";

