=head1 DESCRIPTION

This is intended to test the calling with named arguments,
specifically that we can use different types of values to 
identify the function of interest.

  a) a string giving the name of the R function,
  b) a reference to an R function.

 This is to be invoked as a perl script
   perl namedArgs.pl

 Alternatively, one can call the foo() from R as in 
  .PerlFile(system.file("examples", "namedArgs.pl", package="RSPerl"))
  .Perl("foo")

 One has to avoid the call to initialize R (C<R::initR()>).
 Need a way to detect if we are running from within R already.
=cut

use R;
use RReferences;

R::initR();


# The same test can be done from R by
# calling this sub-routine foo via
#  .Perl("foo")
sub foo {

  my $f = RNamedFunctionReference->new("objects");
  my @x = $f->({pos => 2});
  my $i;

  for $i (@x) {
    print "\t$i\n";
  }

  @x = R::callWithNames("objects", { 'pos' => 2});

  for $i (@x) {
    print "\t$i\n";
  }

  1;
}

foo();
