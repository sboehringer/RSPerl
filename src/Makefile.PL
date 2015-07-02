use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'FIRST_MAKEFILE'  => 'Makefile.perl',
    'MAKEFILE'  => 'Makefile.perl',
    'NAME'	=> 'R',
    'VERSION_FROM' => 'R.pm', 
    'PM' => {'R.pm' => '$(INST_LIBDIR)/R.pm',
             'RReferences.pm' => '$(INST_LIBDIR)/RReferences.pm'
            },
    'LIBS'	=> [ "-L. -L/home/pingu/lib64/R-3.1.3/library/RSPerl/libs -lPerlConverter -Wl,--export-dynamic -fopenmp  -L/home/pingu/lib64/R-3.1.3/lib -lR -llzma -lrt -ldl -lm -licuuc -licui18n" ],   
    dynamic_lib => {'OTHERLDFLAGS' => '-Wl,--export-dynamic -fopenmp  -llzma -lrt -ldl -lm -licuuc -licui18n'},
    'DEFINE'	=> '-g -D_R_=1 -DUSE_R=1 -DWITH_R_IN_PERL=1',    
    'INC'	=> '-I. -I/home/pingu/lib64/R-3.1.3/include',
);
