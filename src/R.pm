package R;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use Carp;

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
 startR	
 AUTOLOAD 
);
$VERSION = '0.01';

bootstrap R $VERSION;

# Preloaded methods go here.

sub startR {
    # If R_HOME is not in the environment table, put in the value from 
    # the installation probes.
    initR(@_);
    return(1);
}

# This used to be a native routine. This is now here to maintain the API
# but we slide in code to set the R_HOME variable if need be.
sub initR {
    if(0) {
	croak("no support for R embedded within Perl");
    }
    setRHome();
    initRSession(@_);
    # Load the RSPerl package. We know the lib.loc so we specify it explicitly
    # which will cause problems if we install a new RSPerl package or point to a new one
    # with R_LIBS and don't use a new R.pm.  We could put /home/pingu/lib64/R-3.1.3/library on the end of the
    # R_LIBS environment variable before loading the R session.
    &R::callWithNames('library', { package => "RSPerl", 'lib.loc' => "/home/pingu/lib64/R-3.1.3/library"});
    return(1);
}

sub setRHome {
    if(!exists($ENV{'R_HOME'})) {
	$ENV{'R_HOME'} = "/home/pingu/lib64/R-3.1.3";
    }
    return(1);
}

sub getDefaultRHome {
    return("/home/pingu/lib64/R-3.1.3");
}

sub mkRef {
 my ($obj) = @_;
 return(\$obj);
}


# Autoload methods go after =cut, and are processed by the autosplit program.


=head1 AUTOLOAD

 This routine allows us to provide a generic implementation
 for undefined routines in the R package/module and so 
 allow shortcuts or syntactic sugar for calls such as
   &R::sum((1, 2, 3))
   &R::plot(\@x, \@y)

 At present, we don't try to handle callWithNames() in this way,
 just call().

 See pages 296-298, Programming Perl by Wall, Christiansen, Orwant.
=cut

sub AUTOLOAD {
     # the name of the method being called is R::method and is in 
     # this package's $AUTOLOAD variable.
    my $name = our $AUTOLOAD;
           # remove the R::, allowing for inheritance, say Rext:: .
    $name =~ s/.*:://;

     # call the R function by this name.
    return(call($name, @_));
}



1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

R - Perl extension for R, the statistical computing environment

=head1 SYNOPSIS

  use R;


=head1 DESCRIPTION

 This module allows one to call R functions, evaluate R expressions
 and access R objects from within the Perl language. R's statistical,
 numeric and graphical functionality are immediately available.

=head1 Calling S Functions

This is is the primary mechanism in this module by which one can invoke an S function
from Perl. The arguments are 
=over 4
=item[1] the name of the S function or an RFunctionReference object
   obtained from an earlier computation
=item[2] an arbitrary number of arguments which are converted to S values
  and used as arguments to the S function, in the same order they 
  are giving here.
=back  

If the value of this call is assigned in Perl or passed on to another
call, the return value from the S function is converted to a Perl
object. Otherwise, it is ignored.


=head1 Call With Named Arguments

This allows one to call an S function, passing
some of the arguments by name rather than position.
The arguments to this are:
=over 4
=item a)
  an identifier for an S function,
  either a name or an C<RFunctionReference>
  object computed in an earlier call.
=item b)
  a hash of name-value pairs.
  Currently, you must name all the arguments.
  In the near future, this will be extended to allow
  an array of names-value pairs with some values allowed to be
  C<''>.
=back

The return value of the S function is converted 
to a Perl object (if the result is assigned).


=head1 Evaluating S expressions

This routine provides a mechanism for evaluating 
S expressions given as strings in the S language.
Because one must first construct the string,
and since it cannot refer to any Perl or anonymous S 
objects, it is less rich that than the 
C<call> and C<callWithNames> routines. However, it is
convenient for evaluating self-contained S expressions
such as interactive queries of the state of the S session,
defining functions and methods, etc.

  @x = R::eval("search");
  R::eval("myFun <<- function(n) { rnorm(n) + 100 }");



=head1 R initialization

Initialize the R engine. This must be done 
 first when running R within Perl,
 before making any calls to R functions or accessing
 R objects. The arguments should be character strings
 as if they were command line arguments to the R 
 process. 

 You can call startR  with command line arguments
 as you would specify them to R for a regular
 command line invocation, e.g.

  initR('--no-save')

 This calls initR in the R.xs code and 
 also loads the RSPerl library into the R
 interpreter, i.e. via a call
     &R::library("RSPerl")

 This library may not be necessary but it is harmless
 if you don't use it. If you need to avoid loading it into the
 R session, use initRSession() instead of initR() in Perl.

=head1  Value of R_HOME environment variable

In order for the embedded R session to be able to find
all the interpreted R code, etc.  it needs to know
where its home directory is located. This is specified
via the environment variable R_HOME.  
If this is not set, initR() can set it based on the value
determined at installation time. This value is accessible
via the routine getDefaultRHome().
initR() sets the value implicitly as necessary,
but if one wants to explicitly set it, use
setRHome().

=head1  Register a user-level converter.

This function allows one to register a user-level converter that are
used when converting a non-primitive S object to a Perl value. When
the conversion is attempted, we loop over all registered converters
and ask the predicate/matching function in the converter whether the
converter can process the S object. If it can (returning TRUE), then
we call the actual converter function in this converter.
One can use closures, etc. to parameterize the converter and matching
routines.

See converter.pl in the examples/ directory.

=head1 Discard R Reference Value

This routine allows us to remove an element in the S reference
manager that maintains a list of the different S objects that have
been exported as references to Perl.  This helps us free resources
being used by S objects for which we no longer need the reference in
Perl. This is rarely used explicitly by the user, but implicitly
during the destruction of an C<RReference> object.



=head1 setDebug()

This allows one to dynamically toggle the debug status
(i.e. the variable C<RPerlDebug>)
for this module. If C<RPerlDebug> is C<TRUE>,
then a very large number of messages are printed to the console
from this module explaining detailing different steps in its activities.


=head1 Loading an S library

This is a convenience mechanism for loading an R library and
processing the return value easily.  This could be deprecated now that
we discard return values that are not assigned in Perl.

  R::library("mva");
  $ok = R::call("library", "mva");

It also gets in the way of an AUTOLOAD for R::library().


=head1 AUTHOR

Duncan Temple Lang duncan@wald.ucdavis.edu
Bug reports to omega-bugs@omegahat.org.


=head1 SEE ALSO

 RReferences

perl(1).

http://www.omegahat.org/RSPerl

=cut

