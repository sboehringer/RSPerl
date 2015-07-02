=head1 DESCRIPTION
 These routines allow us to check whether NULL and undef values
 are being converted correctly from R to Perl and vice-versa.
=head1 SYNOPSIS

 .Perl("checkUndef", NULL)
 .Perl("checkUndef", 1)

 .Perl("checkUndefs", 1, 2)
 .Perl("checkUndefs", 1, NULL)
 .Perl("checkUndefs", NULL, 2)

=cut

sub checkUndef {
    print "In checkUndef()\n";
    my $arg = shift;
    print "Argument defined? ", (defined $arg ? "yes" : "no"),"\n";
    undef;
}

sub checkUndefs {
    print "In checkUndefs()\n";
    my (@args) = @_;
    for $arg (@args) {
	print "Argument defined? ", (defined $arg ? "yes" : "no"),"\n";
    }
    undef;
}



