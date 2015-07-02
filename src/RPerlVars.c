#include "RPerlVars.h"

#include "RPerlNew.h"

#include "Converters.h"
#include "Reflectance.h"

SV *RS_PerlGetSV(USER_OBJECT_ obj);

/*
 */
USER_OBJECT_
RS_PerlUndef(USER_OBJECT_ ids, USER_OBJECT_ types, USER_OBJECT_ interpreter)
{
 int n, nt;
 int i,j;
 const char *id;
 int count;
 USER_OBJECT_ ans;

 n = GET_LENGTH(ids);
 nt = GET_LENGTH(types);

 PROTECT(ans = NEW_LIST(n));

  for(i = 0; i < n; i++) {
    id = CHAR_DEREF(STRING_ELT(ids, i));
    count = 0;

    for(j = 0; i < nt; i++) {
	   if(LOGICAL_DATA(types)[i] == TRUE) {
	     count++;
	     switch(i) {
		     case PERL_SCALAR:
				     
			break;
		     case PERL_ARRAY:
				     
			break;
		     case PERL_HASH:
				     
			break;
		     case PERL_SUB:
				     
			break;
		     default:
                       break;
	     } /* switch() */
	   } /* end of if LOGICAL_DATA() */
    } /* type loop */

    if(count == 0) {
      /* Was a composite identifier such as $x{'y'} so have to handle it specially. */
    }
  } /* ids loop */


  UNPROTECT(1);
  return(ans); 
}


USER_OBJECT_
RS_remove(USER_OBJECT_ ids, USER_OBJECT_ interpreter)
{
  HV *table;
  USER_OBJECT_ ans;
  const char *key;

  dTHX;

   PROTECT(ans = NEW_LOGICAL(1));
   table = gv_stashpv("main", FALSE);

   key = CHAR_DEREF(STRING_ELT(ids,0));
   hv_delete(table, key, strlen(key), G_DISCARD);
 
   LOGICAL_DATA(ans)[0] = TRUE;
   UNPROTECT(1);

  return(ans);
}



/*
   name  the perl variable name to wich the value should be assigned.
 */
USER_OBJECT_
RS_PerlCreateAssign(USER_OBJECT_ name, USER_OBJECT_ vals, USER_OBJECT_ type)
{
  SV * val;
  
  /* This just takes the first element for the moment and ignores type. */
  val = toPerl(VECTOR_ELT(vals,0), FALSE);
  RS_PerlAssign(val, name);


    /* Should we return a Perl reference to the new object? 
       Or how about the old value.
     */
  return(NULL_USER_OBJECT);
}

Rboolean
PerlAssign(SV *val, const char *name, const char *pkg)
{
 HV *table;
 dTHX;

  table = gv_stashpv(pkg != NULL ? (char *)pkg : "main", FALSE);
  if(table == NULL) {
     PROBLEM  "No such package %s", pkg
     ERROR;
  }
     
  if(val == NULL)
    val = newSVsv(&sv_undef);
  SvREFCNT_inc(val);

  hv_store(table, (char*)name, strlen(name), val,0);

 return(TRUE);
}

SV *
RS_PerlGetSV(USER_OBJECT_ obj)
{
 SV *sv = NULL;

 if(IS_CHARACTER(obj)) {
   dTHX;
   HV *table = gv_stashpv("main", FALSE);   
   const char *key = CHAR_DEREF(STRING_ELT(obj, 0));
   SV **tmp = hv_fetch(table, key, strlen(key), 0);
   if(tmp && *tmp)
     sv = *tmp;
   else {
     PROBLEM "No such object %s in Perl's main::", key
     ERROR;
   }
 } else {
   sv = getForeignPerlReference(obj);     
 }

 return(sv);
}

USER_OBJECT_
RS_PerlLength(USER_OBJECT_ obj)
{
 SV *sv;
 int n;
 USER_OBJECT_ ans;
 dTHX;

 sv = RS_PerlGetSV(obj);
 if(!sv) {
   PROBLEM "Can't get Perl object from S object"
   ERROR;
 }

 /*
   Check for 
     a) objects,
     b) references 
   here.
  */

#if 0
 if(sv_isobject(sv)) {
/*XXX What are we warning here. Is it debugging? */
    PROBLEM "Calling length on a Perl object"
    WARN;
 }
#endif

 if(SvROK(sv)) {
     sv = SvRV(sv);
 }

 switch(SvTYPE(sv)) {
    case SVt_PVHV:
       n = hv_iterinit((HV*) sv);
     break;
    case SVt_PVAV:
       n = av_len((AV*) sv) + 1; 
     break;
    default:
      n = 0;
      break;
 }

  ans = NEW_INTEGER(1);
  INTEGER_DATA(ans)[0] = n;

 return(ans);
}

USER_OBJECT_
RS_PerlClear(USER_OBJECT_ obj)
{
 SV *sv;
 int n;
 USER_OBJECT_ ans;
 dTHX;

 ans = NEW_LOGICAL(1);
 sv = RS_PerlGetSV(obj);
 if(sv == NULL)
   return(ans);

 switch(SvTYPE(sv)) {
    case SVt_PVHV:
        hv_clear((HV*) sv);
     break;
    case SVt_PVAV:
        av_clear((AV*) sv); 
     break;
    default:
      n = 1;
      break;
 }

  LOGICAL_DATA(ans)[0] = TRUE;

 return(ans);
}


USER_OBJECT_
RS_PerlNames(USER_OBJECT_ obj)
{

 HV* hv;
 SV *el;
 int n, i; 
 USER_OBJECT_ names;
 char *key;
 I32 len;
 dTHX;

 if(IS_CHARACTER(obj)) {
   hv = get_hv(CHAR_DEREF(STRING_ELT(obj,0)), FALSE);
 } else
  hv = (HV *) RS_PerlGetSV(obj);  

  if(hv == NULL) {
    PROBLEM "identifier does not refer to a Perl hashtable object"
    ERROR;
  }


 if(SvTYPE(hv) != SVt_PVHV) {
      if(SvROK(hv) && SvTYPE(SvRV(hv)) == SVt_PVHV) {
         hv = (HV *) SvRV(hv);
      } else {
	  PROBLEM "identifier is not a Perl hashtable object, but some other type %s", getPerlType((SV*)hv)
	  ERROR;
      }
  }

 n = hv_iterinit(hv);   
 if(n == 0)
   return(NULL_USER_OBJECT);

 PROTECT(names = NEW_CHARACTER(n));
 i = 0;
 while(i < n) {
  el = hv_iternextsv(hv, &key, &len);
  if(key == NULL)
    break;
  SET_STRING_ELT(names, i, COPY_TO_USER_STRING(key));
  i++;
 }

 UNPROTECT(1);
 return(names);
}
