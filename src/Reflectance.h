#ifndef REFLECTANCE_H
#define REFLECTANCE_H

#include "RSPerl.h"

USER_OBJECT_ RS_getStash(USER_OBJECT_ pkg, USER_OBJECT_ converter, USER_OBJECT_ interpreter);

const char *getRSPerlClass(SV *val);
const char * getPerlType(SV *el);
SV *getPerlGlobValue(SV *el);
USER_OBJECT_ computeRSPerlClassVector(SV *val, svtype *, Rboolean convert);
USER_OBJECT_ makeRSPerlClassVector(const char *name);

Rboolean isPerlPrimitive(SV *val);
Rboolean isPerlPrimitiveType(svtype type, SV *val);

Rboolean isHomogeneous(SV *sv, svtype *homogeneousType);

#endif
