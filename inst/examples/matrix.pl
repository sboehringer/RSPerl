=head1 DESCRIPTION

 This is intended to illustrate the basic aspects of 
 converting an R matrix object to a Perl object via
 user-defined converters.
 
=cut

use R;
use RReferences;

=head1 Converter Matching/predicate Routine.

This routine is called by the user-converter
mechanism as it loops over the registered converters
while looking for one that claims it can convert an
R object to Perl. This routine examines the object
and determines whether it is a matrix. If it is,
it returns C<TRUE> so that the associated converter
will be called to convert the object.

=cut 

sub match {
    print "[matrix match]\n";
    my $obj = shift;
    print "[match] ", $obj, " ", ref($obj), "\n";
#    my $ok = R::call("inherits", $obj, "matrix");

    my $type = R::call("typeof", $obj);
    print "Typeof r object ", $type, "\n";
       # if there is more than one class, we need to get this as an array.
    my @class = R::call("class", $obj);
    print "Class: ", $class[0], "\n";
    my $ok = ($class[0] eq "matrix");
    print "In matrix match ", $ok, "\n";
    return($ok);
}

=head1 Converter

  This is the routine that actually does the conversion. It is quite
simple and should be modified to do something useful. It illustrates
how we get a reference to the R object as the only argument to this 
converter and then we can invoke R functions using this object,
typically to query its elements so as to convert them to Perl
values. In this case, we ask for 

=over 4

=item [1]
  the type/mode of the elements of the matrix,

=item [2]
    the dimensions of the R matrix,

=item [3]
 then its values.

=back

These are done via simple C<R::call> invocations.

=cut


sub convert {
    my $obj = shift;
    my $type = R::call("typeof", $obj);
    my @dim = R::call("dim", $obj);
    my @values = R::call("as.vector", $obj);
print "Converted matrix: ", $dim[0], ", ", $dim[1], " ", $#values, "\n";

    return($values);
}

=head1 Registering the converter

  Here we register the converter, specifying both the match and converter routines
  and a description that can be accessed in R using getPerlConverterDescriptions()
  as in
    C<getPerlConverterDescriptions(c(toPerl=T))>
  The final argument is currently ignored, but is intended to control whether we
  automatically should use this converter when we discover an homogenous array of 
  elements that can be processed by this converter.

=cut

R::setConverter(\&match, \&convert, "A simple Perl routine for converting an R matrix", 1);

# R::eval("mgen <<- function() { o <- list(a=1, b='xyz') ; class(o) <- 'Duncan' ; o}");

=head1 An R matrix function
 This defines an R function that returns a matrix.
 We can use this to generate an object in R that 
 is transferred to Perl and will be intercepted by the
 converter. See C<bar> below.

=cut

R::initR("--vanilla");
R::library("RSPerl");
R::eval("mat <<- function() { matrix(rnorm(100), 10, 10) }");

=head1 bar

  This routine calls the C<mat> function in R defined in the command
above. The R function returns a matrix which will then be converted
by the routines registered above into a simple Perl matrix object.

=cut

sub bar {
  my $x = R::call("mat");
  print "Result: ", $x, " ", ref($x), "\n";
  1;
}

bar();
