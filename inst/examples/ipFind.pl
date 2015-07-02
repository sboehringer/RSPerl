use NetAddr::IP::Find;

sub f {
    print "<f> ", $_[0], "</f>\n";
};

$txt = "Some text with 128.32.135.50 and other IP address such as www.omegahat.org";
find_ipaddrs($txt, \&f);

print "And text is:", $txt, "\n"

