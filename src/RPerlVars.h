#ifndef RPERLVARS_H
#define RPERLVARS_H

#include "RSPerl.h"

USER_OBJECT_ RS_PerlUndef(USER_OBJECT_ ids, USER_OBJECT_ types, USER_OBJECT_ interpreter);
Rboolean PerlAssign(SV *val, const char *name, const char *pkg);

enum {PERL_SCALAR, PERL_ARRAY, PERL_HASH, PERL_SUB};

#endif
