This is a fork of the RSPerl module from [https://web.archive.org/web/20160127065417/http://www.omegahat.org/RSPerl]. It has been patched to install with a current version of perl (5.20 as of writing). 

## Installation

### Devtools

```
library('devtools');
install_github('sboehringer/RSPerl');
```

### Command line

```
R CMD INSTALL . --configure-args='--with-in-perl'
```


ToDo:
  * use of perl modules with c-code 
