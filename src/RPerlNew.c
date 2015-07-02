#include "RPerlNew.h"
#include "Converters.h"
#include "Reflectance.h"

#include "RPerlVars.h"

USER_OBJECT_
RS_newPerlArray(USER_OBJECT_ values, USER_OBJECT_ name)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  AV *arr = (AV *) toPerl(values, TRUE);

  ans = RS_PerlAssign((SV *) arr, name);
  
 return(ans);
}

USER_OBJECT_
RS_newPerlTable(USER_OBJECT_ values, USER_OBJECT_ names, USER_OBJECT_ name)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  HV *arr;
  arr = toPerlTable(values, names);

  if(arr == NULL) {
    PROBLEM "no names specified for elements of table"
    ERROR;
  }

  ans = RS_PerlAssign((SV *)arr, name);
  
 return(ans);
}

HV *
toPerlTable(USER_OBJECT_ values, USER_OBJECT_ names)
{
  int n = GET_LENGTH(values), i;
  HV *table;
  char *key;
  SV *el;
  dTHX;

  if(names == NULL_USER_OBJECT || GET_LENGTH(names) != GET_LENGTH(values)) {
    return(NULL);
  }

    /* Need to allocate space for this table. */
  table = newHV();
  for(i = 0; i < n;i++) {
    el = toPerl(VECTOR_ELT(values, i), FALSE);
    SvREFCNT_inc(el);
    key = strdup(CHAR_DEREF(STRING_ELT(names, i)));
    hv_store(table,  key, strlen(key), el, 0);          
  }

  return(table);
}

USER_OBJECT_
RS_PerlAssign(SV *value, USER_OBJECT_ name)
{
  USER_OBJECT_ ans;
  if(GET_LENGTH(name) > 0) {
    /* Here we perform the assignment to the Perl namespace/table
       and then create an S-language object which  identifies the
       variable and name space and gives it a class indicating it is
       a real variable and not a reference.
     */
    ans = RS_makePerlVariable(value, name);
  } else {
    USER_OBJECT_ tmp;
     PROTECT(tmp = NEW_CHARACTER(1));
     SET_STRING_ELT(tmp, 0, COPY_TO_USER_STRING((char *)getRSPerlClass(value)));
     ans = makeForeignPerlReference(value, tmp, NULL);
     UNPROTECT(1);
  }

 return(ans);
}

USER_OBJECT_
RS_makePerlVariable(SV *value, USER_OBJECT_ name)
{
 USER_OBJECT_ ans, tmp, names;


  PerlAssign(value, CHAR_DEREF(STRING_ELT(name,0)), 
  	       GET_LENGTH(name) > 1 ? CHAR_DEREF(STRING_ELT(name,1)) : NULL);

   PROTECT(ans = NEW_LIST(2));
   PROTECT(names = NEW_CHARACTER(2));

   SET_VECTOR_ELT(ans, 0, tmp = NEW_CHARACTER(1));
   SET_STRING_ELT(tmp, 0, STRING_ELT(name, 0));
   SET_STRING_ELT(names, 0, COPY_TO_USER_STRING("name"));

   if(GET_LENGTH(name) > 1) {
    SET_VECTOR_ELT(ans, 1, tmp = NEW_CHARACTER(1));
    SET_STRING_ELT(tmp, 0, STRING_ELT(name, 1));
   }
   SET_STRING_ELT(names, 1, COPY_TO_USER_STRING("module"));

   SET_NAMES(ans, names);

   PROTECT(names = NEW_CHARACTER(1));
   SET_STRING_ELT(names, 0, COPY_TO_USER_STRING("PerlVariable"));
   SET_CLASS(ans, names);
   UNPROTECT(3);
   
 return(ans);
}
