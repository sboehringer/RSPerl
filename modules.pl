#!/usr/bin/perl -s

# This is a perl script that is used to compute the 
# perl modules (currently) in the auto/ directory which have
# C code and so must be explicitly linked to a library that embeds
# Perl in another application. The reason for needing this is to allow
# the embedded Perl interpreter to load the code in a usable manner.
# See http://www.perldoc.com/perl5.6/pod/perlembed.html
#   and the section 
#    "Using modules that themselves use C libraries from your C program".

# Call as
#    perl -s modules.pl -modules
#    perl -s modules.pl 
#    perl -s modules.pl -modules -nofilter
#    perl -s modules.pl -nofilter
#    perl -s Install/modules.pl -modules -omits="Apache2|ModPerl|Gaim"


$els="";

# Can find all the modules this way.
# Have to do more, and also worry about which version of find.
# find `perl -e 'print "@INC"'` -name '*.pm' 


# Here is the main execution point.
# Loop over all the module search directories
# and process the auto/ directories within each.
# For each of these auto/ directories, look for directories
# that have a file named $dir/$dir.so. We have to look
# recursively also for nested modules (e.g. Data::Calc being
# identified as Data/Calc/Calc.so).

use Config;

$SoExtension=$Config{'dlext'};

if ($nofilter == 0 && !defined($omits)) {
    $omits = "Apache2|ModPerl";
}

foreach $dir (@INC) {
     # loop over all the entries in the auto directory.
   opendir DIR, "$dir/auto";

    while($d = readdir DIR) {
    	# When I dyn.load() the RSPerl.so  linked
    	# with the B.so module, I get an error, so skip it.
    	#
       next if $d eq "B";
       next if($d eq "." || $d eq "..");
        
       processDir($d, $d, "$dir/auto/$d");
   }

   closedir DIR;
}

print "$els\n";



sub addEntry {
   local ($subdir, $mod, $d) = @_;

   if ($nofilter == 0 && $mod =~ m/^($omits)/) {
       return(0);
   }

   local($goon) = matchesUserModules($mod);
   if($goon) {
     if ($modules) {
       $els .= "$mod ";
     } else {
       $els .= "$d/$subdir.$SoExtension ";
     }
}
}

sub processDir {
    local ($subdir, $mod, $d) = @_;
    local $x, FOO, $tmp, $dira, $goon;

         # Now if the user gave us the list of modules on
         # the command line, then, 
   	 if (-d "$d") { 
            if( -f "$d/$subdir.$SoExtension") {
        	addEntry($subdir, $mod, $d);
            } else {
                opendir FOO, "$d";
       	          local (@files) = readdir(FOO);
  	          closedir FOO;
		  for $x (@files) {
                      next if ($x eq "." || $x eq "..");
                      if (! -d "$d/$x") {
			  next;
                      }
  	              processDir($x, $mod . "::$x", $d . "/$x");
		  }
	    }
   	 }
}

 # Check the module is in the user specified list of modules
 # of interest. If the user did not specify anything, then 
 # it is considered a match by default, corresponding to the 
 # all modules specification.
sub matchesUserModules {
  local $goon;
   local ($mod) = @_;
       $goon = 0;
       if($#ARGV > -1) {
	   foreach $d (@ARGV) {
	       if($d eq $mod) {
		   $goon=1;
		  break;
 	       }
	   }
       } else {
	   $goon = 1;
       }

    return $goon;
}
