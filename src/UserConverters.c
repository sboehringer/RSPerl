#include "RSPerl.h"

#include "Converters.h"

#include "UserConverters.h"
#include "Reflectance.h"  /* For computeRSPerlClassVector */
#include "ForeignReference.h"

extern ForeignReferenceTable exportReferenceTable;


static SV * invokeFromPerlConverterRoutine(SV *obj, CV *fun, int *ok);


/**
 Loops over the user-registered routines to check if any of them
 can convert the Perl object to an S object.
 Returns NULL if none of the converters admitted to being able to 
 handle the object.
 Otherwise, it returns an S object resulting from converting the 
 Perl value.
 */
USER_OBJECT_ 
userLevelConversionFromPerl(SV *val, unsigned int depth)
{
    RSFromPerlConverter *cvt = FromPerlConverters;

    while(cvt) {
	if(cvt->match(val, NULL, cvt)) {
	    return(cvt->converter(val, NULL, cvt));
	}
	cvt = cvt->next;
    }

    return(NULL);
}


/**
 Loops over the user-registered routines to check if any of them
 can convert the S object to a Perl object.
 Returns NULL if none of the converters admitted to being able to 
 handle the object.
 Otherwise, it returns a Perl object resulting from converting the 
 S value.
 */
SV *
userLevelConversionToPerl(USER_OBJECT_ val)
{
    RSToPerlConverter *cvt = ToPerlConverters;
#if RSPERL_DEBUG
    Rf_PrintValue(val);
#endif
    while(cvt) {
	if(cvt->match(val, NULL, NULL, FALSE, 0, cvt)) {
	    return(cvt->converter(val, NULL, NULL, FALSE, 0, cvt));
	}
	cvt = cvt->next;
    }

    return(NULL);
}


/**
 This is a matching function that simply checks whether the 
 given Perl object -- `obj' -- is an instance of or is derived from
 the class identified in the data stored in the converter object.
 This allows simple inheritance matching without using S functions.
 
 */
Rboolean
FromPerlNameConverterMatch(SV *obj, PerlClassInfoPtr classInfo, RSFromPerlConverter *converter)
{
    SFromPerlConverterFunctionData *data = (SFromPerlConverterFunctionData *) converter->userData;
    dTHX;

    return(sv_derived_from(obj, data->className));
}

/**

  This is a simple routine that acts as a converter matching routine 
  in the direction of Perl to R. It calls an S function
  that determines whether the associated converter can perform
  the conversion of the given Perl object.
 */
Rboolean
FromPerlFunctionConverterMatch(SV *obj, PerlClassInfoPtr classInfo, RSFromPerlConverter *converter)
{
    SFromPerlConverterFunctionData *data = (SFromPerlConverterFunctionData *) converter->userData;
    USER_OBJECT_ e, val;
    int errorOccurred;
    svtype elementType = SVt_NULL;

    PROTECT(e = allocVector(LANGSXP, 2));
    SETCAR(e, data->match);
    SETCAR(CDR(e), makeForeignPerlReference(obj, computeRSPerlClassVector(obj, &elementType, FALSE), &exportReferenceTable));
    val = R_tryEval(e, R_GlobalEnv, &errorOccurred);
    if(errorOccurred)
	return(FALSE);

    UNPROTECT(1);
    return(LOGICAL_DATA(val)[0]);
}


USER_OBJECT_
FromPerlFunctionConverterConvert(SV *obj, PerlClassInfoPtr classInfo, RSFromPerlConverter *converter)
{
    SFromPerlConverterFunctionData *data = (SFromPerlConverterFunctionData *) converter->userData;
    USER_OBJECT_ e, val;
    int errorOccurred = 0;

    PROTECT(e = allocVector(LANGSXP, 2));
    SETCAR(e, data->converter);
    SETCAR(CDR(e), makeForeignPerlReference(obj, NULL_USER_OBJECT, &exportReferenceTable));
    val = R_tryEval(e, R_GlobalEnv, &errorOccurred);

    UNPROTECT(1);
    return(val);
}






/**

  This is a simple routine that acts as a converter matching routine 
  in the direction of Perl to R. It calls an S function
  that determines whether the associated converter can perform
  the conversion of the given Perl object.
 */
Rboolean
FromPerlRoutineConverterMatch(SV *obj, PerlClassInfoPtr classInfo, RSFromPerlConverter *data)
{
   int ok = 0;
   SFromPerlConverterRoutineData *converter = ( SFromPerlConverterRoutineData * )data->userData;
   
   invokeFromPerlConverterRoutine(obj, converter->match, &ok);

   return((Rboolean) ok);
}



USER_OBJECT_
FromPerlRoutineConverterConvert(SV *obj, PerlClassInfoPtr classInfo, RSFromPerlConverter *data)
{
   dTHX;
   SV *perlObj;
   USER_OBJECT_ val;
   SFromPerlConverterRoutineData *converter = ( SFromPerlConverterRoutineData * )data->userData;

   perlObj = invokeFromPerlConverterRoutine(obj, converter->converter, NULL);

      /* Now make this an R object. */
   if(SvROK(perlObj) && sv_isa(perlObj, "RReferences")) {
    val = RPerl_getProxyValue(perlObj);
   } else {
    val = fromPerl(perlObj, TRUE);
   }

 return(val);
}

static SV *
invokeFromPerlConverterRoutine(SV *obj, CV *fun, int *ok)
{
    dTHX;
    dSP;
    int n;

    SV *perlObj = NULL;

    ENTER;
    SAVETMPS;
    PUSHMARK(sp);
    XPUSHs(obj);

    PUTBACK;
    n = call_sv((SV *) fun, G_EVAL | G_KEEPERR); /*  (ok ? G_SCALAR : G_ARRAY) | */

    SPAGAIN;

    if(ok)
      *ok = POPi;
    else {
      perlObj = POPs;
      SvREFCNT_inc(perlObj);
    }

    PUTBACK;
    FREETMPS;
    LEAVE;
    return(perlObj);
}


SV *
callPerlConverterRoutine(USER_OBJECT_ obj, PerlClassInfoPtr classInfo, char *signature, Rboolean isArray, int arrayLen, RSToPerlConverter *cvt, int *ok)
{
    SToPerlConverterFunctionData *data;
    SV *perlObj = NULL, *tmp;
    SV *fun;
    int n;
    dTHX;
    dSP;


    tmp = RPerl_createRProxy(obj);

    data = (SToPerlConverterFunctionData *) cvt->userData;
    fun = (SV *) ((ok == NULL) ? data->converter : data->match);

    ENTER;
    SAVETMPS;
    PUSHMARK(sp);
    XPUSHs(tmp);

    PUTBACK;
    n = call_sv((SV *) fun, G_EVAL | G_KEEPERR); /*  (ok ? G_SCALAR : G_ARRAY) | */

    SPAGAIN;

    if(ok)
      *ok = POPi;
    else {
      perlObj = POPs;
      SvREFCNT_inc(perlObj);
    }

    PUTBACK;
    FREETMPS;
    LEAVE;
    RPerl_discardRProxy(tmp);

    return(perlObj);
}

Rboolean
toPerlFunctionMatch(USER_OBJECT_ obj, PerlClassInfoPtr classInfo, char *signature, Rboolean isArray, int arrayLen, RSToPerlConverter *cvt)
{
   int ok;
   callPerlConverterRoutine(obj, classInfo, signature, isArray, arrayLen, cvt, &ok);

   return(ok);
}

SV *
toPerlFunctionConvert(USER_OBJECT_ obj, PerlClassInfoPtr classInfo, char *signature, Rboolean isArray, int arrayLen, RSToPerlConverter *cvt)
{
   return(callPerlConverterRoutine(obj, classInfo, signature, isArray, arrayLen, cvt, NULL));
}


USER_OBJECT_
RPerl(addConverter)(USER_OBJECT_ match, USER_OBJECT_ converter, 
                     USER_OBJECT_ fromPerl, USER_OBJECT_ sclassName,
                     USER_OBJECT_ description, USER_OBJECT_ autoArray)
{
    char *desc = NULL, *className;
    USER_OBJECT_ ans;
    int index;
    FromPerlConverterMatch matchFun = FromPerlFunctionConverterMatch;

    if(GET_LENGTH(description)) {
	const char *tmp;
	tmp = CHAR_DEREF(STRING_ELT(description, 0));
	desc = (char *) malloc((strlen(tmp) + 1)* sizeof(char));
        strcpy(desc, tmp);
    }

    if(IS_CHARACTER(sclassName) && GET_LENGTH(sclassName)) {
	const char *tmp;
	tmp = CHAR_DEREF(STRING_ELT(sclassName, 0));
	className = (char *) malloc((strlen(tmp) + 1)* sizeof(char));
        strcpy(className, tmp);
	matchFun = FromPerlNameConverterMatch;
    }

    if(fromPerl) {
	SFromPerlConverterFunctionData *data;
	data = (SFromPerlConverterFunctionData *) malloc(sizeof(SFromPerlConverterFunctionData));
	data->match = match;
	if(GET_LENGTH(data->match))
	    R_PreserveObject(data->match);
	data->converter = converter;
	if(GET_LENGTH(data->converter))
	    R_PreserveObject(data->converter);
	if(className) {
	    data->className = className;
	}
	addFromPerlConverterInfo(matchFun,
				 FromPerlFunctionConverterConvert,
				 LOGICAL_DATA(autoArray)[0], data, desc, &index);
    }
  
    ans = NEW_INTEGER(1);
    INTEGER_DATA(ans)[0] = index;
    return(ans);
}


int 
addPerlConverterRoutine(CV *match, CV *converter, int toPerl, char *description, int autoArray)
{
    int index;

    if(description)
        description = strdup(description);


    SvREFCNT_inc(match);
    SvREFCNT_inc(converter);
    if(toPerl) {
        SToPerlConverterFunctionData *data;
        data = (SToPerlConverterFunctionData*) malloc(sizeof(SToPerlConverterFunctionData));
        data->match = match;
	data->converter =  converter;

	addToTargetConverterInfo(toPerlFunctionMatch, toPerlFunctionConvert, autoArray, data, description, &index);
    } else {
        SFromPerlConverterRoutineData *data = (SFromPerlConverterRoutineData *) malloc(sizeof(SFromPerlConverterRoutineData));
	data->match = match;
	data->converter = converter;

        addFromPerlConverterInfo( FromPerlRoutineConverterMatch,  FromPerlRoutineConverterConvert, autoArray, data, description, &index);
    }

    return(index);
}



