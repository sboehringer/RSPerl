{
    package RHashAccessor;

    sub FETCH {
	my ($self, $key) = @_;
	return($self->getEl($key));
    }

}

{
package RReferences;

=head1 NAME

References to external R/S objects.

=head1 SYNOPSIS

 use RReferences;

=head1 DESCRIPTION

 This module provides facilities for exporting R objects
 to Perl as remote references which actually reside in the 
 R part of the process, but are visible to Perl.

=head1 AUTHOR

Duncan Temple Lang duncan@wald.ucdavis.edu

=head1 SEE ALSO

perl(1).

R
http://www.omegahat.org/RSPerl

=cut


=begin comment
 How to run this to check it works!

  perl -e 'use RReferences; $x= &RReferences::new("duncan"); $y = $x->getName(); printf "Answer: $y\n";'
=end   comment

=cut

sub new {
   my ($class, $name) = @_ ; #
   my $obj = { 
               name => $name
             };

   $obj = bless($obj, $class);

   tie $obj, RHashAccessor;

   return($obj);
}

 sub getName {
    my $self = shift;
    print "<getName>", $self->{name}, "\n";
    return($self->{name});
 }

 sub DESTROY {
     my $obj = $_[0];
     # print "Destroying R reference object `", $obj->{name}, "'\n";
     #XXX R::deleteRReference($_[0]);
     1;
 }

 sub asString {
     my $self = shift;
     return("<" . ref($self) . "> " . $self->{name});
 }

# Not used yet since it causes a stack overflow due to infinite
# recursion.
 sub getEl {
   my $this = shift;

   return  R::call('$', $this, @_);
 }



=head1 AUTOLOAD

    Allow the Perl user to make calls to R functions as if they are methods 
   within this R "object", i.e. of the form
       $ref->myMethod(1, 2, "3");
  
    This then becomes a call of the form
        R::call("myMethod", $this, @_)

    i.e. with the reference as the first argument to the R function named myMethod.


=cut


=cut

 sub AUTOLOAD  {
    my $name = our $AUTOLOAD;
    my ($this) = @_;

print "Autoload for references\n";
    $name =~ s/.*:://;
    return(R::call($name, $this, @_));
  }

  use overload q("") => \&asString;
# Thinking about how to allow $ref{"coef"} get the element named coef in the R list.
#               '%{}' => \&getEl;

}


{
 package RFunctionReference;

 our @ISA=qw(RReferences);

 sub call {
   my $this = shift;

   return(sub { 
      R::call($this, @_);
   });
 }

 use overload '&{}' => \&call;
}

{
 package RNamedFunctionReference;

=head1 DESCRIPTION

 Allows one to create a Perl alias to a regular named 
 R function. When the Perl routine is invoked, this calls
 the Perl method R::call() giving the name of the R function.

=cut
 
 our @ISA=qw(RFunctionReference);
 sub call {
   my $this = shift;

   return(sub { 
      R::call($this->{name}, @_);
    });
 }

 use overload '&{}' => \&call;
}

1;
