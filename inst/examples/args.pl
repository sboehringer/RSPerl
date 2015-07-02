sub foo {
    foreach $e (@_) {
	print $e, "\n";
    }
    return(1);
}
