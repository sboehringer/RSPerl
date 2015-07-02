#include "RPerlElements.h"

#include "Converters.h"
USER_OBJECT_
RS_PerlArrayElement(USER_OBJECT_ rs_arr, USER_OBJECT_ elements, USER_OBJECT_ convert)
{
 int i, n;
 AV *arr;
 SV *obj;
 USER_OBJECT_ ans = NULL_USER_OBJECT;
 unsigned int depth;
 dTHX;

 obj = getForeignPerlReference(rs_arr);

 if(obj == NULL) {
   PROBLEM "No such array reference %s", "?"
   ERROR;
 }

 if(SvROK(obj))
     obj = SvRV(obj);

 if(SvTYPE(obj) != SVt_PVAV) {
   PROBLEM "Perl object is not an array %s, but of type %d", "?", (int) SvTYPE(obj)
   ERROR;
 }
 arr = (AV*) obj;

 if(TYPEOF(convert) == LGLSXP || TYPEOF(convert) == INTSXP) 
   depth = (TYPEOF(convert) == LGLSXP ? LOGICAL(convert)[0] : INTEGER(convert)[0]);

  n = GET_LENGTH(elements);
  if(n > 0) {
    SV **el;
    PROTECT(ans = NEW_LIST(n));
    for(i = 0; i < n; i++) {
      el = av_fetch(arr, INTEGER_DATA(elements)[i], 0);
      if(el && *el)
         SET_VECTOR_ELT(ans, i, fromPerl(*el, depth/*XXX handle other cases, like CallModified. Accept a native symbol */));
    }
    UNPROTECT(1);
  }

  return(ans);
}


USER_OBJECT_
RS_PerlHashElement(USER_OBJECT_ rs_table, USER_OBJECT_ elements, USER_OBJECT_ convert)
{
 int i, n;
 HV *table;
 USER_OBJECT_ ans = NULL_USER_OBJECT;
 SV *obj;
 unsigned int depth;
 dTHX;

 obj = getForeignPerlReference(rs_table);
 if(obj == NULL) {
   PROBLEM "No such table reference %s", "?"
   ERROR;
 }

 if(SvROK(obj))
     obj = SvRV(obj);

 if(SvTYPE(obj) != SVt_PVHV) {
   PROBLEM "Perl object (%s) is not a hash,  but of type %d", "?", (int) SvTYPE(obj)
   ERROR;
 }

 table = (HV*) obj;

  if(TYPEOF(convert) == LGLSXP || TYPEOF(convert) == INTSXP) 
     depth = (TYPEOF(convert) == LGLSXP ? LOGICAL(convert)[0] : INTEGER(convert)[0]);
  n = GET_LENGTH(elements);
  if(n > 0) {
    SV **el;
    const char *key;
    PROTECT(ans = NEW_LIST(n));
      /* */
    for(i = 0; i < n ; i++) {
     key = CHAR_DEREF(STRING_ELT(elements,i));
     el = hv_fetch(table, key, strlen(key), 0);
     if(el && *el)
       SET_VECTOR_ELT(ans, i, fromPerl(*el, depth));
    }
    SET_NAMES(ans, elements);
    UNPROTECT(1);
  }

  return(ans);
}

USER_OBJECT_
RS_PerlSetArrayElements(USER_OBJECT_ robj, USER_OBJECT_ index, USER_OBJECT_ value)
{
 
 I32 i, n, which;
 SV *el, *av, *obj;
 USER_OBJECT_ ans = NULL_USER_OBJECT;
 dTHX;

 obj = getForeignPerlReference(robj);

 if(obj == NULL) {
   PROBLEM "No such array reference %s", "?"
   ERROR;
 }

 if(SvROK(obj))
     obj = SvRV(obj);

 if(SvTYPE(obj) != SVt_PVAV) {
   PROBLEM "Perl object is not an array %s, but of type %d", "?", (int) SvTYPE(obj)
   ERROR;
 }

 av = obj;

  n = GET_LENGTH(index);
  for(i = 0; i < n; i++) {
    el = toPerl(VECTOR_ELT(value,i), TRUE);
    /*    SvREFCNT_inc(el); */
    which = INTEGER_DATA(index)[i];
    av_store((AV*)av, (I32) which, el);
  }

  return(ans);
}


USER_OBJECT_
RS_PerlSetHashElements(USER_OBJECT_ robj, USER_OBJECT_ index, USER_OBJECT_ value)
{
 I32 i, n;
 SV *el, *hv;
 const char *key;
 USER_OBJECT_ ans = NULL_USER_OBJECT;
 SV *obj;
 dTHX;

 obj = getForeignPerlReference(robj);
 if(obj == NULL) {
   PROBLEM "No such table reference %s", "?"
   ERROR;
 }

 if(SvROK(obj))
     obj = SvRV(obj);

 if(SvTYPE(obj) != SVt_PVHV) {
   PROBLEM "Perl object (%s) is not a hash,  but of type %d", "?", (int) SvTYPE(obj)
   ERROR;
 }

 hv = obj; 

  n = GET_LENGTH(index);
  for(i = 0; i < n; i++) {
    el = toPerl(VECTOR_ELT(value,i), TRUE);
    SvREFCNT_inc(el);
    key = CHAR_DEREF(STRING_ELT(index, i));
    hv_store((HV*)hv, key, strlen(key), el, 0);
  }

  return(ans);
}
