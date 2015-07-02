#!/usr/bin/perl

=head1 DESCRIPTION
 This is an example of passing a list of functions
 from S to Perl and using these as `methods'.
 We provide examples for two different circumstances examples of this:
 =over
 =item Unnamed
   Here we provide a simple list of S functions
   and Perl assumes the order
 =item Named
   Here we give a named list of S functions and Perl
   uses the names to match them to the methods.
 =back 

=cut

use R;
use RReferences;

{
    package RMethods;

    sub new {
	my $class = shift;
        my $this = [@_];
	for $x (@_) {
	    print "Element: ", ref($x), " ", $x, "\n";
	}
        bless $this, $class;
    }

    sub a {
	my $this = shift;
        my $f = $this->[0];
	print ref($f);
        return($f->(@_));
    }

    sub b {
	my $this = shift;
        my $f = $this->[1];
        return($f->(@_));
    }

    sub c {
	print "In c()\n";
	undef;
    }
}

{
    package RNamedMethods;
    our @ISA = qw(RMethods);

    sub new {
	my $class = shift;
        my $this = {@_};
	print "Element Names: ", join(", ", keys(%$this)), "\n";
        bless $this, $class;
    }

    sub a {
	my $this = shift;
        my $f = $this->{'a'};
	print ref($f), " ", $f->{name}, "\n";
	for $x (@_) { print $x, "\n"; }

        return($f->(@_));
    }

    sub b {
	my $this = shift;
        my $f = $this->{'b'};
	# for $x (@_) { print $x, "\n"; }
        return($f->(\@_));
    }
 

    sub genericMethod {
       my ($this, $args, $what, $name) = @_;
       print "Method name: ", $name, "\n";
       print "Args: ", $args, "\n";
       print "What: ", $what, "\n";
       return(10);
    }

    # Overload the operators that are overloadable.
    # 
   use overload nomethod => \&genericMethod;    
}

# If this were a module, we could conditionally run the following code
# if we were running as a script, and not just use'ing it!

#if(!caller) {
#   $o = RMethods->new();
#   $o->c;
#   print $o, "\n";
#}

R::initR("--quiet");
R::library("RSPerl");

$o = RNamedMethods->new('a' => RNamedFunctionReference->new("sum"),
                        'b' => RNamedFunctionReference->new("mean"));
print "Sum: ", $o->a(1, 2), "\n";
print "Mean: ", $o->b(1, 2, 3), "\n";

# print "prod: ", $o->prod(1, 2, 3), "\n";


