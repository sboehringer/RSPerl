use R;
use RReferences;

package MyClass; 

sub init {
    my $klass = shift;

    my $self = {x => 1, y => 'abc'};
    bless $self, $klass;
}


sub predicate {
    my $obj = shift;
    print "In predicate ", $obj->isa("MyClass"), "\n";
    return($obj->isa("MyClass"));
} 

sub conversion {

    my $obj = shift;
    print "In conversion\n";
    return(R::call("matrix", 0, 3, 5));
}

&R::initR("--silent");

R::library("RSPerl");

R::setConverter(\&predicate, \&conversion, "A simple Perl routine conversion", 0);

# R::eval("print(getPerlConverterDescriptions())");


$obj = MyClass->init();
print "myClass ? ", $obj->isa("MyClass"), "\n";
R::call("print", $obj);
