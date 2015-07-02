#include "Converters.h"

#include "Reflectance.h" /* for getRSPerlClass() */
#include <unistd.h>

#include "ForeignReference.h"


#define USE_NEW_PERL_REFERENCES

ForeignReferenceTable exportReferenceTable;

SV *callFilter(SV *filter, SV *el);

SEXP GetRScalar(SV *val);

USER_OBJECT_
RS_getHV(USER_OBJECT_ name, USER_OBJECT_ convert, USER_OBJECT_ interpreter)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  HV *table;
  dTHX;

  if(!IS_CHARACTER(name)) {
    SV *tmp = getForeignPerlReference(name);
    if(tmp == NULL || SvTYPE(tmp) != SVt_PVHV) {
      PROBLEM "non-array reference passed to RS_getHV"
      ERROR;
    }
    table = (HV*) tmp;
  } else {
    table = get_hv(CHAR_DEREF(STRING_ELT(name,0)), FALSE);
  }

  if(table != NULL) {
   if(TYPEOF(convert) == LGLSXP || TYPEOF(convert) == INTSXP) {
     unsigned int depth;
     depth = (TYPEOF(convert) == LGLSXP ? LOGICAL(convert)[0] : INTEGER(convert)[0]);

     if(depth) {
         ans = fromPerlHV(table, depth);
     } else {
      /*       ans = fromPerl((SV*) table); */
      ans = makeForeignPerlReference((SV*) table, makeRSPerlClassVector("PerlHashReference"), &exportReferenceTable);
    }
   } else {
      ans = directConvertFromPerl((SV*) table, convert);
   }
  }

  return(ans);
}



USER_OBJECT_
RS_getAV(USER_OBJECT_ name, USER_OBJECT_ convert, USER_OBJECT_ elFilter, USER_OBJECT_ interpreter)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  AV *arr;
  dTHX;

  if(!IS_CHARACTER(name)) {
    SV *tmp = getForeignPerlReference(name);
    if(tmp != NULL && SvTYPE(tmp) == SVt_RV) {
      tmp = SvRV(tmp);
    }
     
    if(tmp == NULL || SvTYPE(tmp) != SVt_PVAV) {
      PROBLEM "non-array reference passed to RS_getAV"
      ERROR;
    }
    arr = (AV*) tmp;
  } else {
    arr = get_av(CHAR_DEREF(STRING_ELT(name,0)), FALSE);
  }

  if(arr != NULL) {
   if(TYPEOF(convert) == LGLSXP || TYPEOF(convert) == INTSXP) {
      unsigned int depth;
      depth = (TYPEOF(convert) == LGLSXP ? LOGICAL(convert)[0] : INTEGER(convert)[0]);
      if(depth) {
         SV *filter = NULL;
         if(GET_LENGTH(elFilter))
            filter = getPerlCodeObject(elFilter);
         ans = fromPerlAV(arr, filter, depth);
      } else {
           /*      ans = fromPerl((SV*) arr); */
         ans = makeForeignPerlReference((SV*) arr, makeRSPerlClassVector("PerlArrayReference"), &exportReferenceTable);
     }
   } else 
      ans = directConvertFromPerl((SV *) arr, convert);
  }

  return(ans);
}

#ifdef R_UNUSED
/* The 1000 means convert at all depths and if we get that far, we are in serious trouble. */
USER_OBJECT_
basicFromPerlAV(AV *arr)
{
   return(fromPerlAV(arr, NULL, 1000));
}


USER_OBJECT_
fromPerlHV_SV(SV *sv)
{
  if(SvROK(sv)) {
     sv = SvRV(sv);
  }

  if(SvTYPE(sv) != SVt_PVHV) {
    PROBLEM "fromPerlHV_SV called with Perl object that is not a Hashtable."
    ERROR;
  }

  if(!sv || SvTYPE(sv) == SVt_NULL)
     return(NULL_USER_OBJECT);

   return(fromPerlHV((HV *) sv, 1000));
}
#endif

/*
 Loop over all the key-value pairs and convert
 them to string and USER_OBJECT_ and put the latter
 into an R/S LIST and use the vector of keys as the names.
 */
USER_OBJECT_
fromPerlHV(HV *table, unsigned int depth)
{
 I32 len;
 char *key;
 SV *el;
 I32 n, i;
 Rboolean sameType;
 svtype elType;
 dTHX;

 USER_OBJECT_ names, ans;

 sameType = isHomogeneous((SV*)table, &elType);
 if(sameType && isPerlPrimitiveType(elType, (SV *)table)) {
   return(fromHomogeneousTable((SV *) table, elType));
 }

 n = hv_iterinit(table); 
 i = 0;
 PROTECT(names = NEW_CHARACTER(n));
 PROTECT(ans = NEW_LIST(n));
 while(i < n) {
  el = hv_iternextsv(table, &key, &len);
  if(key == NULL)
    break;
  SET_VECTOR_ELT(ans, i, fromPerl(el, TRUE));
  SET_STRING_ELT(names, i, COPY_TO_USER_STRING(key));
  i++;
 }

 SET_NAMES(ans, names);
 UNPROTECT(2);
 return(ans);
}



USER_OBJECT_
fromPerlAV(AV *arr, SV* filter, unsigned int depth)
{
 I32 n, i;
 SV **el, *tmp;
 Rboolean mustFree;
 USER_OBJECT_ ans;
 svtype elType;
 dTHX;
 Rboolean sameType = SVt_NULL;

 n = av_len(arr); 

#if defined(R_PERL_DEBUG) && R_PERL_DEBUG
 fprintf(stderr, "In fromPerlAV: length %d\n", n);
#endif

 sameType = isHomogeneous((SV*)arr, &elType);
 if(sameType && isPerlPrimitiveType(elType, (SV *)arr)) {
   return(fromHomogeneousArray((SV *) arr, elType));
 }

 PROTECT(ans = NEW_LIST(n+1));
 for(i = 0; i <= n; i++) {
   mustFree = FALSE;
  el = av_fetch(arr, i, 0);
  if(el && *el != NULL) {
    if(filter) {
      tmp = callFilter(filter, *el);
      mustFree = TRUE;
    } else
      tmp = *el;
    
    SET_VECTOR_ELT(ans, i, fromPerl(tmp, TRUE));
    if(mustFree)
      SvREFCNT_dec(tmp);
  }
 }

 UNPROTECT(1);
 return(ans);
}



SV *
callFilter(SV *filter, SV *el)
{
  SV *val;
  I32 n;

 dTHX;
 dSP;
 ENTER;
 SAVETMPS;
 PUSHMARK(sp);

  XPUSHs(el);
  PUTBACK;
  n = call_sv(filter, (G_SCALAR | G_EVAL));
  SPAGAIN;
  val = POPs;
  SvREFCNT_inc(val);

 PUTBACK;
 FREETMPS;
 LEAVE;

   return(val);
}


USER_OBJECT_ 
fromPerlArray(AV *val, unsigned int depth) 
{
 I32 n;
 USER_OBJECT_ ans;
 int i;
 SV **el;
 dTHX;

 if(val == NULL)
    return(NULL_USER_OBJECT);

 n = av_len(val);
 n++;
#ifdef R_PERL_DEBUG
 fprintf(stderr, "Got an array %d\n", (int) n);
#endif
 PROTECT(ans = NEW_LIST(n));
  for(i = 0; i < n; i++) {
    el = av_fetch(val, i, 0);
    SET_VECTOR_ELT(ans, i, fromPerl(*el, TRUE));
  } 
 UNPROTECT(1);
 return(ans);
}

USER_OBJECT_
createPerlReference(SV *val)
{
 USER_OBJECT_ classes, ans = NULL_USER_OBJECT;
 classes = computeRSPerlClassVector(val, NULL, FALSE);

 if(classes && GET_LENGTH(classes)) {
     /* We protect classes in the subroutines. */
   PROTECT(classes);
   ans = makeForeignPerlReference(val, classes, &exportReferenceTable);
   UNPROTECT(1);
 }

 return(ans);
}

USER_OBJECT_ 
fromPerl(SV *val, unsigned int depth)
{
 USER_OBJECT_ ans = NULL_USER_OBJECT;
 USER_OBJECT_ classes;
 svtype type = SvTYPE(val);
 svtype elementType = SVt_NULL;
 svtype refType;
 SV *refVal = NULL;
 dTHX;


 if(type == SVt_PVGV) {
    if(GvHV(val)) 
       ans = fromPerlHV(GvHV(val), depth - 1);
    else if(GvAV(val))
       ans = fromPerlAV(GvAV(val), NULL, depth - 1);
    else if(GvCV(val)) 
       ans = fromPerl((SV *) GvCV(val), 0);
    else if(GvSV(val)) 
       ans = fromPerl(GvSV(val), depth - 1);
    else if(GvIOp(val)) {
          /* XXX */
    } else {
      PROBLEM "Don't understand particular type of PVGV at this point"
      ERROR;
    }
    
    return(ans);
 } else if (type == SVt_PVMG && !sv_isobject(val)) {
	 /* If it is magic and not an object, then treat it as a scalar and
            get it back to R as a value, not a reference.
            Would ideally like to respect the convert option. But
            we can get ourselves into an infinite loop. Needs more investigation.
          */

    return(GetRScalar(val));
 }

 if(val == NULL || val == &sv_undef || (!SvOK(val) && !SvROK(val) && type != SVt_PVCV) /* || type == SVt_NULL */) {

#ifdef R_PERL_DEBUG
     fprintf(stderr, "Null result: %p (%d)  (undef = %p) (type is %s)  SvOK=%d, SvROK=%d\n", 
                       val, type, &sv_undef, type == SVt_NULL ? "null" : "not null", 
                       SvOK(val), SvROK(val)); fflush(stderr);
#endif
    return(NULL_USER_OBJECT);
 }

 if(SvROK(val)) { /* && sv_isobject(val)) { */
     if(sv_isa(val, "RReferences")) {
	 return(RPerl_getProxyValue(val));
     } else {
	 ans = userLevelConversionFromPerl(val, depth);
	 if(ans != NULL)
	     return(ans);
#ifdef R_PERL_DEBUG
	 fprintf(stderr, "Didn't get a user-leve conversion. Continuining with regular conversion\n");
#endif
     }
 }

 classes = computeRSPerlClassVector(val, &elementType, depth);
 if(!depth || (classes && GET_LENGTH(classes))) {
     /* We protect classes in the subroutines. */
   PROTECT(classes);
   ans = makeForeignPerlReference(val, classes, &exportReferenceTable);
   UNPROTECT(1);
   return(ans);
 }

#ifdef R_PERL_DEBUG
fprintf(stderr, "[Converting] element type %d %d %d\n", (int) elementType, (int) SvTYPE(val), (int) (SvTYPE(val) == SVt_RV));
#endif

/*
  If it is a reference, then check whether it is an array or hash.
 */

 if(SvROK(val)) {
     refVal = SvRV(val);
     refType = SvTYPE(refVal);
 } else {
     refVal = val;
     refType = type;
 }


#ifdef R_PERL_DEBUG
 fprintf(stderr, "[fromPerl] refType = %d\n", refType);
#endif

 if(refType == SVt_PVAV ||  refType == SVt_PVHV) {
     if(isHomogeneous(refVal, &elementType)) {
       return( (refType == SVt_PVAV) ? 
	       fromHomogeneousArray(refVal, elementType) :
	       fromHomogeneousTable(refVal, elementType));
     } else {
       return( (refType == SVt_PVAV) ? fromPerlAV((AV*)refVal, NULL, depth) : fromPerlHV((HV*)refVal, depth));
     }
 } else if(refType == SVt_PVCV) {
     return(createPerlReference(refVal));
 }

#ifdef R_PERL_DEBUG
 fprintf(stderr, "[fromPerl] continuing again as refType (%d) was not an array or table.\n", refType);
#endif


 ans = GetRScalar(val);

 return(ans);
}


SEXP 
GetRScalar(SV *val)
{
  dTHX;
  SEXP ans = NULL_USER_OBJECT;

  if(SvIOKp(val)) {
    PROTECT(ans = NEW_INTEGER(1));
    INTEGER_DATA(ans)[0] = SvIV(val);
    UNPROTECT(1);
  } else if(SvNOKp(val)) {
    PROTECT(ans = NEW_NUMERIC(1));
    NUMERIC_DATA(ans)[0] = SvNV(val);
    UNPROTECT(1);
  } else if(SvPOK(val)) {
    PROTECT(ans = NEW_CHARACTER(1));
    SET_STRING_ELT(ans, 0, COPY_TO_USER_STRING(SvPV(val, PL_na)));
    UNPROTECT(1);
  } else if(SvROK(val)) {
    fprintf(stderr, "Not handling nested references in conversion from Perl to R at present. Suggestions for semantics welcome!\n");fflush(stderr);
  } else if(SvTYPE(val) == SVt_PVMG) {
    /*XXX get more info about the type of the magic object. 
    struct magic *mg = SvMAGIC(val);
    */
    PROTECT(ans = createPerlReference(val));

    UNPROTECT(1);
  } else {
    fprintf(stderr, "Cannot deal currently with Perl types %d\n", SvTYPE(val));fflush(stderr);
  }

  return(ans);
}


SEXP
simplifyRList(SEXP l)
{
	int i, n;
	int type = TYPEOF(VECTOR_ELT(l, 0));
        SEXP  el;

	n = GET_LENGTH(l);
	for(i = 1; i < n  ; i++) {
  	  el = VECTOR_ELT(l, i);
          if(type != TYPEOF(el))
    	     return(l);
	}

	if(type != INTSXP && type != LGLSXP && type != STRSXP && type != REALSXP && type != CPLXSXP)
  	  return(l);

	{
		SEXP e;
		PROTECT(e = allocVector(LANGSXP, 2));
		SETCAR(e, Rf_install("unlist"));
		SETCAR(CDR(e), l);
		l = Rf_eval(e, R_GlobalEnv);
		UNPROTECT(1);
	}

	return(l);
}

USER_OBJECT_
R_makePerlReference(USER_OBJECT_ s_obj)
{
   SV *obj, *ref;
   USER_OBJECT_ ans;
   dTHX;

   obj = toPerl(s_obj, TRUE);
   /* SvREFCNT_inc(obj); not needed */
   ref = newRV_inc(obj);
   ans = createPerlReference((SV*) ref);
   return(ans);
}


SV *
toPerl(USER_OBJECT_ val, Rboolean perlOwned)
{
 int n = GET_LENGTH(val);
 dTHX;
 SV *sv = &sv_undef;

  if(val == NULL_USER_OBJECT)
     return(sv);

  if(isRSReferenceObject(val)){
    return(getForeignPerlReference(val));
  }

  if(GET_LENGTH(GET_CLASS(val))) {
      SV *o = userLevelConversionToPerl(val);
      if(!o)
	  return(o);
  }


 if(n == 1) {
  if(IS_CHARACTER(val))
      sv = newSVpv(CHAR_DEREF(STRING_ELT(val, 0)), 0);
  else if(IS_LOGICAL(val))
      sv = newSViv(LOGICAL_DATA(val)[0]);
  else if(IS_INTEGER(val))
      sv = newSViv(INTEGER_DATA(val)[0]);
  else if(IS_NUMERIC(val))
      sv = newSVnv(NUMERIC_DATA(val)[0]);
  else if(IS_FUNCTION(val)) 
      sv = RPerl_createRProxy(val);
 } else {
  AV *arr;
  int i;
    arr = newAV();
    SvREFCNT_inc(arr);
    if(n > 0)
      av_extend(arr, n);
 /* Did try using av_make() and storing the SVs in an array first, but didn't fix the problem
    of bizarre array.
  */
 for(i = 0; i < n ; i++) {
  if(IS_CHARACTER(val))
      sv = newSVpv(CHAR_DEREF(STRING_ELT(val, i)), 0);
  else if(IS_LOGICAL(val))
      sv = newSViv(LOGICAL_DATA(val)[i]);
  else if(IS_INTEGER(val))
      sv = newSViv(INTEGER_DATA(val)[i]);
  else if(IS_NUMERIC(val))
      sv = newSVnv(NUMERIC_DATA(val)[i]);

  SvREFCNT_inc(sv);
  av_push(arr, sv);
 }
   sv = (SV *) arr;
   SvREFCNT_dec(arr);

#if 0
  {SV *rv = newSVrv(arr, NULL);
   sv = rv;
  }
#endif
 }

 if(perlOwned)
#if 0 /*XXX Just experimenting */
   sv = sv_2mortal(sv);
#else
   sv = SvREFCNT_inc(sv);
#endif

 return(sv);
}

void
Rperl_ReleaseReference(SEXP el)
{
  SV *sv = R_ExternalPtrAddr(el);
  dTHX;
  if(sv)
      SvREFCNT_dec(sv);

}

USER_OBJECT_
makeForeignPerlReference(SV *ref, USER_OBJECT_ classes, ForeignReferenceTable *table)
{
 int n;
 USER_OBJECT_ rsRef, el;
 char *key;
 dTHX;

#ifdef USE_NEW_PERL_REFERENCES

  SvREFCNT_inc(ref);
  /* We make this into a list with the external pointer inside it as the first element
     as some of the R code wants to treat it like a list. We will gradually remove this.*/
  rsRef = NEW_LIST(1);
  PROTECT(rsRef);
  SET_VECTOR_ELT(rsRef, 0, el = R_MakeExternalPtr((void *) ref, Rf_install("PerlReference"), R_NilValue));
  R_RegisterCFinalizer(el, Rperl_ReleaseReference);
  SET_NAMES(rsRef, mkString("ref"));
  if(GET_LENGTH(classes)) {
     SET_CLASS(rsRef, classes);
  }
  UNPROTECT(1);

#else

 if(table == NULL)
   table= &exportReferenceTable;

 if(table->entries == NULL) {
   table->entries = newHV();
   SvREFCNT_inc(table->entries);
   n = 0;
 } else
   n = table->numReferences;

 key = (char *) calloc(15, sizeof(char));
 if(!key) { 
   PROBLEM  "Cannot allocaate 15 bytes for perl foreign reference key"
   ERROR;
 }
 sprintf(key, "%ld", (long) n);
 hv_store(table->entries, key, strlen(key), ref, 0);
 SvREFCNT_inc(ref);

 table->numReferences++;

 rsRef = makeRSReferenceObject(key, classes, table);
#endif 

 return(rsRef);
}


USER_OBJECT_
RS_PerlReferenceCount()
{
  USER_OBJECT_ ans;
  ForeignReferenceTable *table= &exportReferenceTable;
  dTHX;
  
   PROTECT(ans =  NEW_INTEGER(2));
   if(table->entries != NULL) {
     INTEGER_DATA(ans)[0] = hv_iterinit(table->entries);
     INTEGER_DATA(ans)[1] = table->numReferences;
   }
   UNPROTECT(1);

 return(ans);
}


USER_OBJECT_
RS_GetPerlReferenceObjects(USER_OBJECT_ which)
{
  USER_OBJECT_ ans, tmp;
  int n, i = 0;
  ForeignReferenceTable *table= &exportReferenceTable;
  SV *el;
  char *key;
  I32 len;
  dTHX;

   if(table->entries == NULL) {
     return(NULL_USER_OBJECT);
   }
   
   n = GET_LENGTH(which);
   if(n == 0) {
     n = hv_iterinit(table->entries);
     PROTECT(ans = NEW_LIST(n)); 
     while(i < n) {
       el = hv_iternextsv(table->entries, &key, &len);
       if(el == NULL)
	 break;
       tmp = makeRSReferenceObject(key, computeRSPerlClassVector(el, NULL, TRUE), table);
       SET_VECTOR_ELT(ans, i, tmp);
       i++;
     }

   } else {


   }

 return(ans);
}



USER_OBJECT_
RS_discardPerlForeignReference(USER_OBJECT_ obj)
{
 const char *key;
 USER_OBJECT_ ans = NEW_LOGICAL(1);


#ifndef USE_NEW_PERL_REFERENCES
  if(IS_CHARACTER(obj)) {
    key = CHAR_DEREF(STRING_ELT(obj, 0));
  } else {
    key = CHAR_DEREF(STRING_ELT(VECTOR_ELT(obj, 0), 0));
  }

  LOGICAL_DATA(ans)[0] = discardPerlForeignReference(key, NULL);
#else

  SV *el;
  dTHX;

  el = getForeignPerlReference(obj);
  if(el) {
      SvREFCNT_dec(obj);
      LOGICAL_DATA(ans)[0] = 1;
  }
#endif

 return(ans);
}

#ifdef USE_NEW_PERL_REFERENCES
Rboolean
discardPerlForeignReference(const char *name, ForeignReferenceTable *table)
{
 SV *el;
 Rboolean status = FALSE;
 dTHX;

  if(table == NULL) {
    table = &exportReferenceTable;
  }

  if(table->entries == NULL)
    return(FALSE);

  el = hv_delete(table->entries,  name, strlen(name), G_DISCARD);
  status = TRUE;

 return(status);
}
#endif



SV *
getForeignPerlReference(USER_OBJECT_ obj)
{
  SV *val;
#ifndef USE_NEW_PERL_REFERENCES
  ForeignReferenceTable *table = &exportReferenceTable;
  SV **el;
  char *key;
#endif
  dTHX;

#ifdef USE_NEW_PERL_REFERENCES
   obj = VECTOR_ELT(obj, 0);
   if(TYPEOF(obj) != EXTPTRSXP) {
      PROBLEM "Non-external pointer object passed when expecting a reference to Perl object"
      ERROR;
   }

   if(R_ExternalPtrTag(obj) != Rf_install("PerlReference")) {
      PROBLEM "NULL value found for reference to Perl object"
      ERROR;
   }
   val = (SV *) R_ExternalPtrAddr(obj);
   if(!val) {
      PROBLEM "NULL value found for reference to Perl object"
      WARN;
   }
   return(val);
#else
   key = CHAR_DEREF(STRING_ELT(VECTOR_ELT(obj, 0), 0));
   el = hv_fetch(table->entries, key, strlen(key), 0);

   if(el == NULL)
     return(NULL);
 return(*el);
#endif
}


#define NUM_REF_SLOTS 4
enum { ID_SLOT, TABLE_SLOT, PID_SLOT, CLASS_SLOT };

USER_OBJECT_
makeRSReferenceObject(char *id, USER_OBJECT_ classes, ForeignReferenceTable *table)
{
 USER_OBJECT_ ans, names, tmp;
 char *slotNames[] = {"id", "table", "pid", "class"};
 int i;
 
  if(classes && GET_LENGTH(classes)) {
    PROTECT(classes);
  }

  PROTECT(ans =  NEW_LIST(NUM_REF_SLOTS));
    SET_VECTOR_ELT(ans, ID_SLOT, tmp = NEW_CHARACTER(1));
      SET_STRING_ELT(tmp, 0, COPY_TO_USER_STRING(id));

    SET_VECTOR_ELT(ans, TABLE_SLOT, tmp = NEW_CHARACTER(1));
       /* No name yet. */
    SET_VECTOR_ELT(ans, PID_SLOT, tmp = NEW_NUMERIC(1));
      NUMERIC_DATA(tmp)[0] = getpid();

  PROTECT(names = NEW_CHARACTER(NUM_REF_SLOTS));
   for(i = 0; i < NUM_REF_SLOTS;  i++)
      SET_STRING_ELT(names, i, COPY_TO_USER_STRING(slotNames[i]));

   SET_NAMES(ans, names);
   if(classes && GET_LENGTH(classes))
       SET_CLASS(ans, classes);


  UNPROTECT(2);
  if(GET_LENGTH(classes)) {
   UNPROTECT(1);
  }

 return(ans);
}

Rboolean
isRSReferenceObject(USER_OBJECT_ val)
{
  return(isRSObject(val, "PerlReference"));
}

Rboolean
isRSObject(USER_OBJECT_ val, const char *className)
{
 USER_OBJECT_ klass = GET_CLASS(val);
 int i;

 /* In Splus (6, at least) klass may be NULL. */
 if(klass == NULL || GET_LENGTH(klass) < 1)
    return(FALSE);

  for(i = 0; i < GET_LENGTH(klass); i++) {
   if(strcmp(className, CHAR_DEREF(STRING_ELT(klass, i)))==0)
     return(TRUE);
  }

 return(FALSE);
}

/*
  Returns the Perl reference to the Code object
  (sub-routine, method, etc.) identified by the S
  character vector `name'.
*/
SV *
getPerlCodeObject(USER_OBJECT_ name)
{
  SV *val;
  SV *tmp;
  Rboolean recurse = FALSE;
  dTHX;

  if(IS_CHARACTER(name)) {
     val = (SV *) get_cv(CHAR_DEREF(STRING_ELT(name, 0)), FALSE);
     return(val);
  } else
     tmp = getForeignPerlReference(name);

  if(tmp == NULL)
    return(NULL);

  do {
    recurse = FALSE;
     switch(SvTYPE(tmp)) {
      case SVt_PVGV:
	      /*XXX Is this correct? or should it be GvCV() */
    	tmp = GvSV(tmp);
    	recurse = TRUE;
    	break;
      case SVt_PVCV:
    	val = tmp;
    	break;
      case SVt_RV:
	val = SvRV(tmp);
    	break;
      default:
       val = NULL;
       getPerlType(tmp);
       break;
     }
  } while(recurse);

  return(val);
}

/*
  This assumes that `val' is actually a Perl array
  and that elementType identifies a _primitive_ Perl
  type and that all the elements in the array are of 
  that type. This then creates an S vector of
  the corresponding type and populates it with the
  elements of the array.
*/
USER_OBJECT_
fromHomogeneousArray(SV *val, svtype elementType)
{
 USER_OBJECT_ ans;
 SV *av,  **gar;
 int n, i = 0;
 dTHX;


 if(SvROK(val))
   av = SvRV(val) ;
 else
   av = val;

 n = av_len((AV *) av);

#if defined(R_PERL_DEBUG) && R_PERL_DEBUG
 fprintf(stderr, "fromHomogeneousArray: length = %d\n", n);
#endif


 if(n < 0)
     return(NULL_USER_OBJECT);

 if(elementType == SVt_NULL) {
     SV **el;
     i = 0;
     while(i < n + 1 && elementType == SVt_NULL) {
	     el = av_fetch((AV *) av/* was val */, i, 0);
	     if(el) 
		elementType = SvTYPE(*el);
	     i++;
     }

     if(elementType == SVt_NULL) {
	 PROBLEM "Cannot determine the type of the elements in the array"
	     ERROR;
     }
 }

   PROTECT(ans = PerlAllocHomogeneousVector(n+1, elementType));

#if defined(R_PERL_DEBUG) && R_PERL_DEBUG
 fprintf(stderr, "[fromHomogeneousArray] Element type %d %d\n", elementType, TYPEOF(ans));
#endif

   for(i = 0; i <= n; i++) {
     gar = av_fetch((AV *) av, i, 0);
     if(gar && *gar) {
#if defined(R_PERL_DEBUG) && R_PERL_DEBUG
      fprintf(stderr, "adding element %d in homogeneous array %d\n", i, elementType);
#endif
       PerlAddHomogeneousElement(*gar, i, ans, elementType);
     }
#if defined(R_PERL_DEBUG) && R_PERL_DEBUG
     else {
	     fprintf(stderr, "skipping element in homogeneous array %d\n", i);
     }
#endif
   }

   UNPROTECT(1);
  return(ans);
}

/*
  This assumes that `val' is actually a Perl Hash table
  and that elementType identifies a _primitive_ Perl
  type and that all the elements in the table are of 
  that type. This then creates an S vector of
  the corresponding type and populates it with the
  elements of the table and puts the names of the elements
  as the names of the S vector.
*/
USER_OBJECT_
fromHomogeneousTable(SV *val, svtype elementType)
{
 USER_OBJECT_ ans, names;
 SV *av,  *el;
 I32 len;
 char *key;
 int n, i;
 dTHX;

 if(SvROK(val))
   av = SvRV(val) ;
 else
   av = val;

   n = hv_iterinit((HV *) av);

   PROTECT(ans = PerlAllocHomogeneousVector(n, elementType));
   PROTECT(names = NEW_CHARACTER(n));
   for(i = 0; i < n; i++) {
     el = hv_iternextsv((HV *) av, &key, &len);
     if(el) {
       PerlAddHomogeneousElement(el, i, ans, elementType);
     }
     if(key && key[0]) {
       SET_STRING_ELT(names, i, COPY_TO_USER_STRING(key));
     }
   }

   SET_NAMES(ans, names);
   UNPROTECT(2);
  return(ans);
}


/*
 This allocates an S vector of the type corresponding
 to the Perl primitive type given in `elementType'
 and of length n.

 See PerlAddHomogeneousElement() below.
*/
USER_OBJECT_
PerlAllocHomogeneousVector(int n, svtype elementType)
{
 USER_OBJECT_ ans = NULL_USER_OBJECT;
   switch(elementType) {
     case SVt_IV:
     case SVt_PVIV:
       ans = NEW_INTEGER(n);
       break;
     case SVt_NV:
     case SVt_PVNV:
       ans = NEW_NUMERIC(n);    
       break;
     case SVt_PV:
       ans = NEW_CHARACTER(n);    
       break;
     default: 
       ans = NEW_LIST(n);    
/*
       PROBLEM "No code written yet to handle Perl type %d",
                 elementType
       ERROR;
*/
       break;
   }

   return(ans);
}

/*
 Converts and inserts the Perl primitive value `val' 
 into the R/S object `ans' in position `i'.
 It knows the type of the Perl object and hence the 
 S object type.

 See PerlAllocHomogeneousVector() above.
 */
void
PerlAddHomogeneousElement(SV *val, int i, USER_OBJECT_ ans, svtype elementType)
{
  dTHX;
     switch(elementType) {
      case SVt_IV:
         INTEGER_DATA(ans)[i] = SvIV(val);
 	 break;
      case SVt_PVIV:
         INTEGER_DATA(ans)[i] = SvIV(val);
 	 break;
      case SVt_NV:
         NUMERIC_DATA(ans)[i] = SvNV(val);
 	 break;
      case SVt_PVNV:
         NUMERIC_DATA(ans)[i] = SvNV(val);
 	 break;
      case SVt_PV:
         SET_STRING_ELT(ans, i, COPY_TO_USER_STRING(SvPV(val, PL_na)));
 	 break;
      case SVt_RV:
	      SET_VECTOR_ELT(ans, i, fromPerl(sv_isobject(val) ? val : val/*XXX SvRV(val)*/, 1));
 	 break;
      case SVt_PVMG: /* magic variable */
	      /*XXX */ SET_VECTOR_ELT(ans, i, fromPerl(val, 0));
      break;
      case SVt_PVGV: /* glob value*/
         SET_VECTOR_ELT(ans, i, fromPerl(val, 1));
 	 break;
      case SVt_NULL:
        if(TYPEOF(ans) == VECSXP)
            SET_VECTOR_ELT(ans, i, R_NilValue);
        else
          fprintf(stderr, "Unhandled NULL object at position %d in array conversion into R object of type %d\n", i, TYPEOF(ans));
	 break;
       default:
        fprintf(stderr, "Unhandled type %d at position %d in array conversion\n", elementType, i);
        break;
     }
}

USER_OBJECT_
directConvertFromPerl(SV * perlObj, USER_OBJECT_ convert)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;

  if(TYPEOF(convert) == CLOSXP) {
     SEXP e, ref;
     PROTECT(e = allocVector(LANGSXP, 2));
     SETCAR(e, convert);

     PROTECT(ref = makeForeignPerlReference((SV*) perlObj, makeRSPerlClassVector("PerlReference"), &exportReferenceTable));
/* Alternative way of creating the reference.
     SEXP classes;
     PROTECT(classes = computeRSPerlClassVector(val, &elementType, convert));
     PROTECT(ref = makeForeignPerlReference(perlObj, classes, &exportReferenceTable)); 
*/
     SETCAR(CDR(e), ref);
     ans = Rf_eval(e, R_GlobalEnv);

     UNPROTECT(2);
  } else if(TYPEOF(convert) == EXTPTRSXP) {
     FromPerlNativeConverter f;
     if(R_ExternalPtrTag(convert) != Rf_install("native symbol")) {
       PROBLEM  "Unrecognized external pointer passed to directConvertFromPerlRoutine"
       ERROR;
     }
     f = (FromPerlNativeConverter)  R_ExternalPtrAddr(convert);
     ans = f(perlObj);
  }

  return(ans);
}
