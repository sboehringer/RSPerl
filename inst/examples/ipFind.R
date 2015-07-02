library(RSPerl)
.PerlPackage(c("RReferences", "R"))

.PerlPackage("NetAddr::IP::Find")

ipCollector =
function()
{
  ips = list()
  list(callback = function(ip, orig) {
                    ips[[orig]] <<- ip
                  },
       ips = function() ips)
}  

cb = ipCollector()

txt = "Some text with 128.32.135.50 and other IP address such as www.omegahat.org and 192.168.0.2 and something stupid like 123.456.789.1";

r = mkRef( txt)
.Perl('find_ipaddrs', r, cb$callback, pkg = "NetAddr::IP::Find")

# Note that the NetAddr::IP::Find modifies the text in r as it processes it.
# So we have to create a new instance again.
r = mkRef( txt)
.Perl('find_ipaddrs', r, function(x, ...) print(x$addr()), pkg = "NetAddr::IP::Find")


# The following do not work.

.Perl('find_ipaddrs', txt, function(x, ...) print(x$addr()), pkg = "NetAddr::IP::Find")
.Perl('find_ipaddrs', RSPerl::mkRef(txt), cb)






