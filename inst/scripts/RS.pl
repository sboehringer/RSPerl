{
package RS;

sub findModule {

    my ($mod) = @_;

   $mod =~ s|::|/|;
   $modName = $mod;
   $modName =~ s|.*/||g;

   foreach $dir (@INC) {
       $x = "$dir/$mod" . ".pm";

       if ( -f $x ) {
          return $dir;
       }
   }

   #return 0;
  }

}

1;
