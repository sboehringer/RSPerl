This is a fork of the RSPerl module from [http://www.omegahat.org/RSPerl]. It has been patched to install with a current version of perl (5.20 as of writing). 

```
R CMD INSTALL . --configure-args='--with-in-perl'
```

To load the package, issue:
```
l = .libPaths()[1];
Sys.setenv(PERL5LIB = sprintf('%s/RSPerl/scripts:%s/RSPerl/perl/x86_64-linux-thread-multi/:%s',
	l, l, Sys.getenv('PERL5LIB')));
library('RSPerl');
```

These inconveniences will be fixed.

ToDo:
  * allow installation with `devtools`