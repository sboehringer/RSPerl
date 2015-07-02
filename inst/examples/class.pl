{
 package MyClass;
 
 sub new {
     my $class = shift;
     my $this = {
        dummy => 'default value',
        @_
     };
     $this->{'foo'} = 1;
     bless $this, $class;
     return($this);
 } 

 sub count {
     my $this = shift;
     print "In count\n";
     print ref($this), "\n";

    foreach $x (keys %{$this}) {
	   print $x,"\n";
    }
    1;
 }
}

#$x = MyClass->new('abc' => 1);
#print "Count: ", $x->count, "\n";
1;
