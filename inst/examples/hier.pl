{
    package hier;

    sub new {
       my $class = shift;
       my $this = [
                    [1, 2], 
                    {'a' => "abc", 'b' => 2},
                    @_ 
                  ];

       bless $this, $class;
    }
  
    sub print {
	my $this = shift;
 
        for $x (@{$this->[0]}) {
	    print $x, "\n";
	}

        for $x (keys %{$this->[1]}) {
	    print $x, "\n";
	}
	
	1;
    }
}

=head DESCRIPTION

 .PerlFile(system.file("examples", "hier.pl", package = "RSPerl"))
 x <- .Perl("getNestedHash")
 names(x)
 .PerlLength(x)
 x[["a"]]
 x[["b"]]
 .PerlLength(x[["c"]])
 x[["c"]][1]   # 1
 x[["c"]][2]   # c(2, 3)

 names(x[["d"]])
 x[["d"]]["x"] # 1
 x[["d"]]["y"] # "abc"
 x[["d"]]["z"] # list(beta = c(1,2,3,4), alpha= "abc")

=cut
sub getNestedHash {
    my $this =  {

      a => [1, 2, 3],
      b => [1, 2, "xyz"],
      c => [1, [2, 3], 5],
      d => {
          x => 1,
          y => "abc",
          z => {
                 'alpha' => "abc",
                 'beta' => [1..4]
               }
      }
  };

    return($this);
}


sub seq {
  my @x = 1..4;
  print "Length: ", $#x, "\n";
  return(@x);
}
