$x = 1;

sub ntpClean {
    my ($a) = @_;
    $a =~ s/ .*//;
    return $a;
}

sub StrLen {
    my ($a) = @_;
    $x = length($a);
    print "In Reverse $a $x\n";

    return $x;
}


sub Reverse {
    my ($a) = @_;
    $x = reverse($a);
    print "In Reverse $a $x\n";
    return $x;
}


sub test {
    my ($a) = @_;

    printf "test: $a\n";
    return 1;
}

sub testArray {
#    my ($a) = @_;
    return ('a', 'b', 'cde', 'fghi');
}

sub testHash {
    my %x;
    $x{"a"} = "asdas";
    $x{"b"} = "abc";

    return \%x;
}

sub Join {
   my  ($p, @l) = @_;
   printf "In Join p=$p,  l=@l, $#l \n";

   local $x = join($p, @l);
   printf "Ans: $x\n";

   return $x;
}

sub Sum {
  my (@l) = @_;
  local $total = 0;
  foreach $arg (@_) {
   $total += $arg;
  }
  return $total;
}


