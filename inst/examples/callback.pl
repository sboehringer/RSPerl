use R;
use RReferences;

=pod SYNOPSIS

From R, source this file using .PerlFile and the call the
checkRCallback sub-routine.  The result should be a list/vector giving
the names of the different elements returned via the R expression
C<objects(2)>.

  .PerlFile(system.file("examples", "callback.pl", package="RSPerl"))
  rx <- .Perl("checkRCallback")

  .Perl("namedFun")
  .Perl("anonFun", function(n, cmd= 10) {paste(n, cmd, "\n"); n + 1})

  .Perl("testRefs")
=cut



sub checkRCallback {
#  &R::setDebug(1);
  @x = &R::eval("objects(2)");

  return(@x);
}


sub testRefs {
    my $i = 1;
    for $x (@_) {
	print $i++, ") ",  ref($x);
#        print $x->{name} if defined ref($x) && $x->isa(RReferences);
        print "\n";
    }
    return(1);
}


sub anonFun {
    my ($fun) = @_;
    print ref($fun), "\n";
    my $x = $fun->(100);
    print "Success ",  $x, "\n";
    $x = $fun->(1, "and a string");
}

sub namedFun {
    my $fun = RNamedFunctionReference->new("search");
    my @els = $fun->();

    print "# elements in R search path: ", ($#els + 1), "\n";
    my $i = 1;
    for $x (@els) {
	print $i++, ") ", $x, "\n";
    }

    1;
}
