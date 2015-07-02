
use NetAddr::IP::Find;

use attributes 'get';

my $p = prototype(\&NetAddr::IP::Find::find_ipaddrs);
print $p, "\n";

use Bio::DB::GenBank;
$p = prototype(\&Bio::DB::GenBank::get_Stream_by_id);
print $p, "\n";

exit 0;

my @a = get(\&NetAddr::IP::Find::find_ipaddrs);

print $#a, "\n";
print @a,"\n";

