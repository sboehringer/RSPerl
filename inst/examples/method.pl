#!/usr/bin/perl
{
        package Mine ;

        sub new
        {
            my($type) = shift ;
	    printf "In Mine::new\n";
            bless [@_];
        }

        sub Display
        {
            my ($self, $index) = @_ ;
            print "$index: $$self[$index]\n" ;
	    return $$self[$index];
        }

        sub PrintID
        {
            my($class) = @_ ;
            print "This is Class $class version 1.0\n" ;
        }
}


$a = new Mine ('red', 'green', 'blue') ;
$a->Display(1) ;
PrintID Mine;
