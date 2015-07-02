=head1 DESCRIPTION

 This checks the garbage collection of R foreign references exported
to Perl. When the reference object in Perl is no longer need, the
DESTROY method of the references should be called called.  These communicate with the R
reference handler and remove the reference
to the associated R object.

=cut

use R;
use RReferences;

sub foo {
    R::call("data", "mtcars");
    my $df = R::call("get", "mtcars");

    print $df, " ", ref($df), "\n";
    1;
}

sub bar {
   my $df = R::call("get", "exists");
   print $df, " ", ref($df), "\n";
   1;
}

sub foobar {
   $myGlobal = R::call("get", "exists");
   print $myGlobal, " ", ref($myGlobal), "\n";
   1;
}

sub checkGlobal {
   print $myGlobal, " ", ref($myGlobal), "\n";
}


sub x {
   my $foo = RReferences->new("myName");
   print "Reference ", $foo->{name},"\n";
   1;
}


# x();
# print "Done\n";
# 1;

