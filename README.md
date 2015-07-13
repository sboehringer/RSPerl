This is a fork of the RSPerl module from [http://www.omegahat.org/RSPerl]. It has been patched to install with a current version of perl (5.20 as of writing). 

```
R CMD INSTALL . --configure-args='--with-in-perl'
```

To load the package, issue:
```
library('RSPerl');
```

These inconveniences will be fixed.

ToDo:
  * allow installation with `devtools`
  * use of perl modules with c-code 