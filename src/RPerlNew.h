#ifndef RPERLNEW_H
#define RPERLNEW_H

#include "RSPerl.h"

HV *toPerlTable(USER_OBJECT_ values, USER_OBJECT_ names);
USER_OBJECT_ RS_makePerlVariable(SV *value,  USER_OBJECT_ name);
USER_OBJECT_ RS_PerlAssign(SV *value,  USER_OBJECT_ name);

#endif

