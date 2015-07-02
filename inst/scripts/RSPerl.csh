if(${?LD_LIBRARY_PATH}) then
 setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/home/pingu/lib64/R-3.1.3/library/RSPerl/libs:-Wl,--export-dynamic -fopenmp /home/pingu/lib64/R-3.1.3/lib
else
 setenv LD_LIBRARY_PATH /home/pingu/lib64/R-3.1.3/library/RSPerl/libs:-Wl,--export-dynamic -fopenmp /home/pingu/lib64/R-3.1.3/lib
endif

if("/home/pingu/lib64/R-3.1.3/library/RSPerl/perl" != "") then
 if(${?PERL5LIB}) then
   setenv PERL5LIB ${PERL5LIB}:/home/pingu/lib64/R-3.1.3/library/RSPerl/perl
 else
   setenv PERL5LIB /home/pingu/lib64/R-3.1.3/library/RSPerl/perl
 endif
endif


