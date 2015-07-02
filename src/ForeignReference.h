#ifndef R_PERL_FOREIGN_REFERENCE_H
#define R_PERL_FOREIGN_REFERENCE_H

USER_OBJECT_ RPerl_setDefaultHandler(USER_OBJECT_ handler);
USER_OBJECT_ RPerl_getRForeignReference(char *name);
USER_OBJECT_ RPerl_createRForeignReference(USER_OBJECT_ value);
SV *RPerl_createRProxy(USER_OBJECT_ value);
USER_OBJECT_ RPerl_getProxyValue(SV *pref);
SV *RPerl_getReferenceName(SV *pref);
char *getRReferenceNameDirect(SV *rref);
int RPerl_discardRProxy(SV *rref);
#endif
