#ifndef CONVERTERS_H
#define CONVERTERS_H

#include "RSPerl.h"

USER_OBJECT_ fromPerlHV(HV *table, unsigned int depth);
USER_OBJECT_ fromPerlAV(AV *arr, SV *filter, unsigned int depth);

USER_OBJECT_ fromPerl(SV *val, unsigned int depth);
USER_OBJECT_ fromPerlArray(AV *val, unsigned int depth);
USER_OBJECT_ createPerlReference(SV *val);


SV *toPerl(USER_OBJECT_ val, Rboolean perlOwned);

typedef struct {
 HV* entries;
 unsigned long numReferences;
} ForeignReferenceTable;


typedef USER_OBJECT_ (*FromPerlNativeConverter)(SV *val);

USER_OBJECT_ directConvertFromPerl(SV * perlObj, USER_OBJECT_ convert);


USER_OBJECT_ makeRSReferenceObject(char *id, USER_OBJECT_ classes, ForeignReferenceTable *table);
USER_OBJECT_ makeForeignPerlReference(SV *ref, USER_OBJECT_ classes, ForeignReferenceTable *table);
SV *getForeignPerlReference(USER_OBJECT_ obj);
Rboolean isRSReferenceObject(USER_OBJECT_ val);


Rboolean discardPerlForeignReference(const char *name, ForeignReferenceTable *table);

Rboolean isRSObject(USER_OBJECT_ val, const char *className);
SV *getPerlCodeObject(USER_OBJECT_ name);


USER_OBJECT_ fromHomogeneousArray(SV *val, svtype elementType);
USER_OBJECT_ fromHomogeneousTable(SV *val, svtype elementType);

USER_OBJECT_ PerlAllocHomogeneousVector(int n, svtype elementType);
void PerlAddHomogeneousElement(SV *val, int i, USER_OBJECT_ ans, svtype elementType);

USER_OBJECT_ makeForeignPerlReference(SV *ref, USER_OBJECT_ classes, ForeignReferenceTable *table);


SV *userLevelConversionToPerl(USER_OBJECT_ val);
USER_OBJECT_ userLevelConversionFromPerl(SV *val, unsigned depth);


SEXP simplifyRList(SEXP l);

#endif
