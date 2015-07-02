#include "Reflectance.h"
#include "Converters.h"

enum {PERL_CV, PERL_AV, PERL_HV, PERL_SV};

static int UseOldBehaviour = 1;

void
R_setOldBehaviour(int *val)
{
 UseOldBehaviour = *val;
}


/*
 This retrieves a list of all the objects in a given package.
 The package name should be give as Module::SubModule (rather
 than Module::SubModule:: as you would ordinarily use in Perl).

 This is rather simple given the primitives we already have.
 We simple get the internal hashtable containing the package
 elements, and pass it to the usual Perl to R converter for that type.
*/
USER_OBJECT_
RS_getStash(USER_OBJECT_ pkg, USER_OBJECT_ convert, USER_OBJECT_ interpreter)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  HV *table;
  unsigned int depth;
  dTHX;

  table = gv_stashpv(CHAR_DEREF(STRING_ELT(pkg, 0)), FALSE);
  /*XXX doesn't handle other types of convert */
  depth = (TYPEOF(convert) == LGLSXP ? LOGICAL(convert)[0] : INTEGER(convert)[0]);
  if(table != NULL) {
    if(depth) {
       ans = fromPerlHV(table, depth);
    } else {
       ans = createPerlReference((SV*) table);
    }
  }

  return(ans);
}

USER_OBJECT_
RS_getStashFromCode(USER_OBJECT_ s_code)
{
    SV *cv;
    HV *stash;
    USER_OBJECT_ ans;
    cv = getForeignPerlReference(s_code);
    stash = CvSTASH(cv);


/*  This get's caught in the test for SvOK(), SvROK() and != SVt_PVCV 
    ans = fromPerl((SV*) stash, FALSE); 
*/
    /* We put the PerlStashReference class on the resulting object in the R code. */
    ans = createPerlReference((SV*) stash);

    return(ans);
}



/*
 This retrieves a reference to a Perl subroutine or module/package method.
 This returns an object whose R class is PerlCodeReference.
*/
USER_OBJECT_
RS_getCV(USER_OBJECT_ name, USER_OBJECT_ pkg, USER_OBJECT_ interpreter)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  CV *el;
  dTHX;
   el = get_cv(CHAR_DEREF(STRING_ELT(name,0)), FALSE);

  if(el != NULL) {
       ans = fromPerl((SV*) el, FALSE);
  }

  return(ans);
}

/*
 Determines whether a variable with a specified name is defined.

 This should have a package.
*/

USER_OBJECT_
RS_PerlExists(USER_OBJECT_ what, USER_OBJECT_ pkg, USER_OBJECT_ type)
{
  USER_OBJECT_ ans = NULL_USER_OBJECT;
  Rboolean tmp = FALSE;
  dTHX;

  const char *name = CHAR_DEREF(STRING_ELT(what,0));

  if(GET_LENGTH(pkg)) {
    HV *table;
      table = gv_stashpv(CHAR_DEREF(STRING_ELT(pkg,0)), FALSE);
      if(table == NULL) {
        PROBLEM "No such Perl package %s", CHAR_DEREF(STRING_ELT(pkg,0))
        ERROR;
      }
      tmp = (hv_fetch(table, name, strlen(name), FALSE) != NULL);
  } else {

    switch(INTEGER_DATA(type)[0]) {
      case PERL_CV:
   	tmp = (get_cv(name , FALSE) != NULL);
   	break;
      case PERL_AV:
   	tmp = (get_av(name , FALSE) != NULL);
   	break;
      case PERL_HV:
   	tmp = (get_hv(name , FALSE) != NULL);
   	break;
      case PERL_SV:
   	tmp = (get_sv(name , FALSE) != NULL);
   	break;
    }
  }
   
  ans = NEW_LOGICAL(1);
  LOGICAL_DATA(ans)[0] = tmp;

  return(ans);
}


USER_OBJECT_
RS_getPerlType(USER_OBJECT_ ref, USER_OBJECT_ pkg, USER_OBJECT_ interpreter)
{
 USER_OBJECT_ ans;
 const char *name;
 SV *el;
 int len = 1;

 if(IS_CHARACTER(ref)) {
   /* Now find the object in the top-level package
      as a variable.
      Perhaps the user should fetch the object and the pass
      it to us as a reference. I am not certain what happens
      if we get a Perl object without asking for it via the 
      routines that also convert it (i.e. perl_get_cv(),
      perl_get_av(), ...
    */

   HV *table;
   const char *key;
   SV **tmp;
   dTHX;
   if(GET_LENGTH(pkg) == 0)
    table = gv_stashpv("main", FALSE);   
   else
    table = gv_stashpv(CHAR_DEREF(STRING_ELT(pkg, 0)), FALSE);   

   key = CHAR_DEREF(STRING_ELT(ref, 0));
   tmp = hv_fetch(table, key, strlen(key), 0);

   if(tmp && *tmp)
     el = *tmp;
   else {
     PROBLEM "No such object %s in Perl's main::", key
     ERROR;
   }
 } else
  el = getForeignPerlReference(ref);  


  name = getPerlType(el);
 
  if(SvTYPE(el) == SVt_PVGV) {
    len = 2;
  }

  PROTECT(ans = NEW_CHARACTER(len));
  SET_STRING_ELT(ans, 0, COPY_TO_USER_STRING(name));
   if(SvTYPE(el) == SVt_PVGV) {
     const char *second = NULL;
     SV *foo= getPerlGlobValue(el);
     if(foo) {
       second = getPerlType(foo);
     }

     if(second)
       SET_STRING_ELT(ans, 1, COPY_TO_USER_STRING(second));
   }
  UNPROTECT(1);

 return(ans);
}

/*
 This finds the type of the value a glob refers to.
*/
SV *
getPerlGlobValue(SV *el)
{ 
 SV *tmp;
     if(GvAV(el)) {
       tmp = (SV *) GvAV(el);
     } else if(GvHV(el)) {
        tmp = (SV *) GvHV(el);
     } else if(GvIO(el)) {
        tmp = (SV *)GvIO(el);
     } else if(GvFORM(el)) {
        tmp = (SV *) GvFORM(el);
     } else if(GvCV(el)) {
        tmp = (SV *) GvCV(el);
     } else
        tmp = NULL;

 return(tmp);
}

/*
  Return a simple, human readable, identifier for the type of the
  Perl object.
*/
const char *
getPerlType(SV *el)
{
 const char *name;
 switch(SvTYPE(el)) {
   case SVt_PVHV:
     name = "hash";
     break;
   case SVt_PVAV:
     name = "array";
     break;
   case SVt_IV:
     name = "integer";
     break;
   case SVt_PV:
     name = "string";
     break;
   case SVt_NV:
     name = "double";
     break;
   case SVt_PVGV:
     name = "glob";
     break;
   case SVt_PVCV:
     name = "code";
     break;
   case SVt_PVIO:
     name = "IOhandle";
     break;
   case SVt_RV:
     name = "reference";
     break;
   default: 
     name = "?";
     break;
 }

 return(name);
}

/*
 This creates an R/S character vector of length 2
 containing the elements "PerlReference" and the
 specified value `name'.
 This is intended to be used to create the class 
 vector for a Perl reference object, and is called
 when one already knows the type of the Perl object
 being referenced. Otherwise, call computeRSPerlClassVector()
 when you don't know its type.
*/

USER_OBJECT_
makeRSPerlClassVector(const char *name)
{
 USER_OBJECT_ classes;
 PROTECT(classes = NEW_CHARACTER(2));
  SET_STRING_ELT(classes, 0, COPY_TO_USER_STRING("PerlReference"));
  SET_STRING_ELT(classes, 1, COPY_TO_USER_STRING(name));

 UNPROTECT(1);

return(classes);
}

/*
 Determines whether the Perl object `val' is a
 Perl primitive (real, integer or string) or not.
*/
Rboolean 
isPerlPrimitive(SV *val)
{
  return(isPerlPrimitiveType(SvTYPE(val), val));
}

Rboolean 
isPerlPrimitiveType(svtype type, SV *val)
{
 Rboolean ans = FALSE;
  switch(type) {
     case SVt_IV:
     case SVt_NV:
     case SVt_PV:
     case SVt_PVIV:
     case SVt_PVNV:
       ans = TRUE;
       break;
     case SVt_RV:
       ans = isPerlPrimitive(SvRV(val));
       break;
     case SVt_PVMG:
        /* This is potentially very dangerous, but works for ENV. */
       ans = TRUE; /* isPerlPrimitive(SvMG(val));*/
       break;
     default:
       ans = FALSE;
       break;
  }
 return(ans);
}

/*
 This computes the character vector classes
 for the Perl Reference object corresponding to the
 Perl object `val'.
 This always consistes of the class name PerlReference,
 and then a name corresponding to the particular type
 of `val' found by calling getRSPerlClass().
 If the type of `val' is a reference or a glob,
 then we look at the object to which it refers and 
 add that as a third class type. This is not the type of
 the object `val' but that of the object to which it refers.
 However, it is useful to present this to the R programmer/user
 and is also used when dispatching as we can resolve a reference or a
 glob object to its referenced value.

 See also makeRSPerlClassVector()  for when one knows the 
 R class name.
*/
USER_OBJECT_
computeRSPerlClassVector(SV *val, svtype *homogeneousType, Rboolean doConvert)
{
 USER_OBJECT_ classes;
 int n = 2, current = 0;
 const char *tmp = NULL;
 svtype type = SVt_NULL;
 dTHX;

 if(doConvert == TRUE && isPerlPrimitive(val))
   return(NULL_USER_OBJECT);

 type = SvTYPE(val);
 if(SvROK(val)) {
     SV *r = SvRV(val);
     if(sv_isobject(val)) {
	 tmp = HvNAME(SvSTASH(r));
     } else {
	 svtype refType = SvTYPE(r);

         if(doConvert && UseOldBehaviour) /* Old behaviour. */
            return(NULL_USER_OBJECT);

	 if(refType == SVt_PVAV || refType == SVt_PVHV) {
      	     SEXP ans;
	     PROTECT(ans = NEW_CHARACTER(2));
	     SET_STRING_ELT(ans, 0, COPY_TO_USER_STRING(getRSPerlClass(r)));
	     SET_STRING_ELT(ans, 1, COPY_TO_USER_STRING("PerlReference"));
	     UNPROTECT(1);
	     return(ans);
		 //     return(NULL_USER_OBJECT);
	 }
     }
 }

#ifdef R_PERL_DEBUG
 fprintf(stderr, "homogeneous reference? %d, %d, %d, %d\n", SvTYPE(val) == SVt_RV, SvROK(val), doConvert, SvTYPE(val));
#endif

 /* Not certain we need the homogeneity here. Mixed logic all over the place. 
     &&    isHomogeneous(val, homogeneousType))
 */
 if(tmp == NULL && (type == SVt_PVAV || type == SVt_PVHV) && doConvert) {
   return(NULL_USER_OBJECT);
 }

 if(type == SVt_PVGV || type == SVt_RV || type == SVt_PVMG)
   n = 3;

 PROTECT(classes = NEW_CHARACTER(n));

 if(tmp) {
    SET_STRING_ELT(classes, current++, COPY_TO_USER_STRING(tmp));
 } else {
#if 0
    if(type == SVt_PVMG) {
	double value = SvNV(val); 
	double xvalue = SvNVx(val); /* What's the x again?*/
        int    ival = SvIV(val);
        int    ixval = SvIVx(val);
        double z = value + 10;
    }
#endif
    tmp = getRSPerlClass(val);
    if(tmp)
      SET_STRING_ELT(classes, current++, COPY_TO_USER_STRING(tmp));
 }

 if(type == SVt_PVGV) {

   SV *tmp = getPerlGlobValue(val);
   if(tmp)
     SET_STRING_ELT(classes, current++, COPY_TO_USER_STRING(getRSPerlClass(tmp)));

 } else if(SvROK(val)/*type == SVt_RV*/) {

   SV *tmp = SvRV(val);
   if(tmp) 
        SET_STRING_ELT(classes, current++, COPY_TO_USER_STRING(getRSPerlClass(tmp)));

 } else if(type == SVt_PVMG) {

   SV *tmp = val;
   const char *k = getRSPerlClass(tmp);

   svtype tt = SvTYPE(tmp);
#if 0
   int obj = sv_isobject(tmp);
#endif
   int rok = SvROK(val);
   const char *kname = NULL;
   if(rok) {
      HV *st = SvSTASH(SvRV(val));
     if(st)
         kname = HvNAME(st);
   }
   if(k)
        SET_STRING_ELT(classes, current++, COPY_TO_USER_STRING(k));

 }

 SET_STRING_ELT(classes, current++, COPY_TO_USER_STRING("PerlReference"));

 classes = SET_LENGTH(classes, current);

 UNPROTECT(1);
 return(classes);
}

const char *
getRSPerlClass(SV *val)
{
 const char *name;
 switch(SvTYPE(val)) {
   case SVt_PVHV:
     name = "PerlHashReference";
     break;
   case SVt_PVAV:
     name = "PerlArrayReference";
     break;
   case SVt_IV:
     name = "PerlInteger";
     break;
   case SVt_PV:
     name = "PerlString";
     break;
   case SVt_NV:
     name = "PerlDouble";
     break;
   case SVt_PVNV:
     name = "PerlStringNumber";
     break;
   case SVt_PVIV:
     name = "PerlStringInteger";
     break;
   case SVt_PVCV:
     name = "PerlCodeReference";
     break;
   case SVt_PVIO:
     name = "PerlIOhandleReference";
     break;
   case SVt_RV:
     name = "PerlReferenceReference";
     break;
   case SVt_PVGV:
     name = "PerlGlobReference";
     break;
   case SVt_PVFM:
     name = "PerlFormatReference";
     break;
   case SVt_PVLV:
     name = "PerlLvalueReference";
     break;
   case SVt_PVBM: /* Like Magic objects, but tailored for very fast lookup 
                     BM => Boyer-Moore.
                     See http://gisle.aas.no/perl/illguts/ 
                   */
     name = "PerlBMReference";
     break;
   default: 
     name = NULL;
     break;
 }

 return(name);
}


       /* The idea here is to iterate over all the elements
          of the array and see if all the elements are of the same type.
        */
Rboolean
isHomogeneous(SV *val, svtype *homogeneousType)
{
  SV *sv, *el, **gar;
  int n, i;  
  I32 len; char *key;
  svtype type = SVt_NULL, elType;
  Rboolean ok = TRUE;
  dTHX;

  if(SvROK(val))
    return(isHomogeneous(SvRV(val), homogeneousType));

   sv = val;
   switch(SvTYPE(sv)) {
     case SVt_PVAV:
       n = av_len((AV *)sv) + 1;
       break;
     case SVt_PVHV:
       n = hv_iterinit((HV*)sv);
       break;
     default:
       return(FALSE);
       break;
   }

   for(i = 0; i < n; i++) {

      switch(SvTYPE(sv)) {
    	case SVt_PVAV:
    	  gar = av_fetch((AV *)sv, i, 0);
    	  if(gar)
	      el = *gar;
    	  break;
    	case SVt_PVHV:
    	  el = hv_iternextsv((HV *) sv, &key, &len);
    	  break;
      }

      if(!el)
	  continue;
      elType = SvTYPE(el);
      if(type != SVt_NULL && type != elType
	 && /* Check if we have a pointer value with an integer and a regular integer,
               or a pointer value with a numeric and a regular numeric.
               XXX Are we certain that the converters handle both of these approriately?
                
               Also, if we have one element that is an integer and another that is a real 
               (SVt_IV and SVt_NV) allow that.
             */
    	  !((type == SVt_NV && elType == SVt_PVNV) ||
	    (type == SVt_PVNV && elType == SVt_NV) ||
	    (type == SVt_IV && elType == SVt_PVIV) ||
	    (type == SVt_IV && elType == SVt_NV) ||
	    (type == SVt_NV && elType == SVt_IV) ||
  	    (type == SVt_PVIV && elType == SVt_IV))) 
 {
          return(FALSE);
      }
      if(!(type == SVt_NV && elType == SVt_IV)) {
         /* Only set the type to IV if it wasn't already the more general NV,
            i.e. don't narrow the type. 
          */
	  type = elType;
      }
   }


     if(ok == TRUE) {
       if(homogeneousType)
	 *homogeneousType = type;

       return(TRUE);
     }

 return(FALSE);
}
