#include "RSPerl.h"
#include "RSCommon.h"
#include "tryEval.h"

#include "Converters.h"

#include "ForeignReference.h"


USER_OBJECT_ RPerl_ForeignReferenceHandler = NULL;

void R_PreserveObject(USER_OBJECT_);


USER_OBJECT_
RPerl_setDefaultHandler(USER_OBJECT_ handler)
{
    USER_OBJECT_ current;
    current = RPerl_ForeignReferenceHandler;

    RPerl_ForeignReferenceHandler = handler;
    R_PreserveObject(RPerl_ForeignReferenceHandler);

    if(current == NULL)
	current = NULL_USER_OBJECT;
    else
	R_ReleaseObject(current);

    return(current);
}

/**
 Don't call this from Perl for the moment. Doesn't share the
 same C variable instance and so returns NULL. Instead, 
 call the S function getPerlHandler().
 */
USER_OBJECT_
RPerl_getDefaultHandler()
{
	if(!RPerl_ForeignReferenceHandler) {
           PROBLEM "RSPerl foreign reference handler object has not been registered"
   	   ERROR;
	}

    return(RPerl_ForeignReferenceHandler);
}

/**

 */
USER_OBJECT_
RPerl_getRForeignReference(char *name)
{
    USER_OBJECT_ e, val = NULL_USER_OBJECT, fun, tmp;
    int errorOccurred;

    PROTECT(e = allocVector(LANGSXP, 2));

     /* Get the getReference() function in the handler. */
    fun = VECTOR_ELT(RPerl_getDefaultHandler(), 4);
    SETCAR(e, fun);
    SETCAR(CDR(e), tmp = NEW_CHARACTER(1));
    SET_STRING_ELT(tmp, 0, COPY_TO_USER_STRING(name));

    val = R_tryEval(e, R_GlobalEnv, &errorOccurred);
    if(errorOccurred) {
  	  /* Need to throw Perl exception. */
	return(NULL_USER_OBJECT);    
    }
    return(val);
}

/**
  This calls an R function to register the R object with the
  R-level foreign reference handler which then returns an identifier
  for that object within its reference table. This is a pure R arrangement
  that does not go to Perl in anyway. See RPerl_createRProxy() which uses
  this routine to export the reference to R.
 */
USER_OBJECT_
RPerl_createRForeignReference(USER_OBJECT_ value)
{
    USER_OBJECT_ e, val = NULL_USER_OBJECT, fun;
    int errorOccurred;

    if(value == NULL || value == NULL_USER_OBJECT)
	return(NULL_USER_OBJECT);

        
    PROTECT(e = allocVector(LANGSXP, 1));
    SETCAR(e, Rf_install("getPerlHandler"));   
    fun = R_tryEval(e, R_GlobalEnv, &errorOccurred);
    if(errorOccurred || fun == NULL || fun == R_NilValue) {
	dTHX;
        UNPROTECT(1);
	croak("Can't get reference handler\n");
  	  /*XXX Need to throw Perl exception. */
	return(NULL_USER_OBJECT);    
    }

    PROTECT(fun = VECTOR_ELT(fun, 1));

    PROTECT(e = allocVector(LANGSXP, 2));

#if 0
     /* Get the createReference() function in the handler. */
    if(RPerl_getDefaultHandler() == NULL) {
	fprintf(stderr, "No reference handler\n");fflush(stderr);
    }
    Rf_PrintValue(RPerl_getDefaultHandler());
    fun = VECTOR_ELT(RPerl_getDefaultHandler(), 1);
#endif

    SETCAR(e, fun);
    SETCAR(CDR(e), value);

    val = R_tryEval(e, R_GlobalEnv, &errorOccurred);
    if(errorOccurred || val == NULL || val == R_NilValue) {
	dTHX;
        UNPROTECT(3);
	croak("Can't get reference handler\n");
  	  /*XXX Need to throw Perl exception. */
	return(NULL_USER_OBJECT);    
    }


    UNPROTECT(3);
    return(val);
}

SV *getPerlCodeObject(USER_OBJECT_);

int
RPerl_discardRProxy(SV *rref)
{
    USER_OBJECT_ e, h;
    int errorOccurred;
    char *name;
    USER_OBJECT_ tmp;

    PROTECT(e = allocVector(LANGSXP, 1));
    SETCAR(e, Rf_install("getPerlHandler"));   
    h = eval(e, R_GlobalEnv);

    PROTECT(e = allocVector(LANGSXP, 2));
    SETCAR(e, VECTOR_ELT(h, 3));
    SETCAR(CDR(e), tmp = NEW_CHARACTER(1));

    name = getRReferenceNameDirect(rref);
    
    SET_STRING_ELT(tmp, 0, COPY_TO_USER_STRING(name));

    R_tryEval(e, R_GlobalEnv, &errorOccurred);

    UNPROTECT(2);

    return(errorOccurred == 0);
}

char *
getRReferenceNameDirect(SV *rref)
{
    HV *table = (HV *) SvRV(rref);
    char *key;
    SV *el;
    I32 len, n, i = 0;
    dTHX;

    n = hv_iterinit((HV*) table);   
    while(i < n) {
	el = hv_iternextsv(table, &key, &len);
	if(strcmp(key, "name") == 0) {
	    return(SvPV(el, PL_na));
	}
    }
    return(NULL);
}

/**
  Stores the given R `value' with the R reference manager
  and then creates a Perl object to represent that object.
 */
SV *
RPerl_createRProxy(USER_OBJECT_ value)
{
  USER_OBJECT_ ref;
  SV *ans;
  char *perlClassName = "RReferences";
  int perlReturnType = G_ARRAY, n;

  dTHX;
  dSP;

  ENTER;
  SAVETMPS;
  PUSHMARK(sp);

  PROTECT(ref = RPerl_createRForeignReference(value));
  
  /*
     .PerlNew("RReferences", value$name) 
   */
  if(IS_FUNCTION(value)) {
      perlClassName = "RFunctionReference";
  }
  XPUSHs(sv_2mortal(newSVpv(perlClassName, 0))); 
  XPUSHs(sv_2mortal(newSVpv(CHAR_DEREF(STRING_ELT(VECTOR_ELT(ref, 0), 0)), 0)));
  PUTBACK;
  n = call_method("new", perlReturnType | G_EVAL | G_KEEPERR);
  if (SvTRUE(ERRSV)) {
      /* error */
      POPs;
      UNPROTECT(1);
      PUTBACK; 
      FREETMPS; 
      LEAVE;
      return(&PL_sv_undef);
  }

  SPAGAIN;

  ans = POPs;
  SvREFCNT_inc(ans);

  PUTBACK; 
  FREETMPS; 
  LEAVE;

  UNPROTECT(1);

  return(ans);
}

/**
  Resolve the R reference whose name or identifier is `name'.
  This gets the R reference handler, and calls its getReference()
  method. It does so with the argument computed by calling
  RPerl_getReferenceName() on the RReference object 
 */
USER_OBJECT_
RPerl_getProxyValue(SV *pref)
{
    USER_OBJECT_ e, fun, value, tmp;
    int errorOccurred;
    dTHX;

    pref = RPerl_getReferenceName(pref);

    PROTECT(e = allocVector(LANGSXP, 1));
    SETCAR(e, Rf_install("getPerlHandler"));   
    PROTECT(fun = eval(e, R_GlobalEnv));

    PROTECT(fun = VECTOR_ELT(fun, 4));
    PROTECT(e = allocVector(LANGSXP, 2));
    SETCAR(e, fun);

    SETCAR(CDR(e), tmp = NEW_CHARACTER(1));
    SET_STRING_ELT(tmp, 0, COPY_TO_USER_STRING(SvPV(pref, PL_na)));
    SvREFCNT_dec(pref);

    value = R_tryEval(e, R_GlobalEnv, &errorOccurred);

    UNPROTECT(4);

    return(value);
}

/**
  Call the getName() method for the RReferences object passed to
  this routine. Returns the Perl string which is the value of the
  name of the identifier.
 */
SV *
RPerl_getReferenceName(SV *pref)
{
 SV *val;
 int n;

 dTHX;
 dSP;

 ENTER;
 SAVETMPS;
 PUSHMARK(sp);
 XPUSHs(pref);
 PUTBACK;

 n = call_method("RReferences::getName", G_SCALAR | G_EVAL | G_KEEPERR);
 val = POPs;

 SvREFCNT_inc(val);

 PUTBACK;
 FREETMPS;
 LEAVE;

 return(val);
}
