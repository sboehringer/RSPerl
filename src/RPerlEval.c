#include "RSPerl.h"
#include "Utils.h"

#include <unistd.h> /* For getpid(). */

#include "Converters.h"


#define UNUSED(x) /**/
/*
 Evaluate a Perl expression in the form of a string.
*/
USER_OBJECT_
RS_PerlEvalString(USER_OBJECT_ expr, USER_OBJECT_ Interpreter, 
                   USER_OBJECT_ convert, USER_OBJECT_ evalStyle)
{
 USER_OBJECT_ ans = NULL_USER_OBJECT;
 I32 style;
 UNUSED(PerlInterpreter *interp = RS_resolvePerlInterpreter(Interpreter));
 const char *cmd;
 SV* val;

 dTHX;

  style = G_EVAL | G_KEEPERR;
  style = 0;
  cmd = CHAR_DEREF(STRING_ELT(expr, 0));

  val = eval_pv(cmd, style);



  if(SvTRUE(ERRSV)) {
      char tmp[1000];
      snprintf(tmp, sizeof(tmp)-1, "%s", SvPV(ERRSV, PL_na));
      tmp[sizeof(tmp)-1] = '\0';
      sv_setpv(ERRSV,"");
      PROBLEM "Error evaluating %s: %s", cmd, tmp
      ERROR;
   }

  if(!GET_LENGTH(convert))
      return(ans);

  if(TYPEOF(convert) == LGLSXP)
     ans = fromPerl(val, LOGICAL(convert)[0]);
/*XXX Convert using the value of convert */

 return(ans);
}


/* 
  Parse and evaluate the contents of a Perl script contained in the 
  file(s) identified by args.
  The script(s) is not evaluated if run is FALSE.
  The extensions object identifies a C routine which Perl uses to load
  other Perl modules that the scripts may need.
 */

EXTERN_C void xs_init(pTHXo);

USER_OBJECT_
RS_PerlEvalFile(USER_OBJECT_ args, USER_OBJECT_ run, USER_OBJECT_ extensions, USER_OBJECT_ Interpreter)
{
 USER_OBJECT_ ans = NULL_USER_OBJECT;
 PerlInterpreter *interp = RS_resolvePerlInterpreter(Interpreter);
 int argc;
 char **argv;
 int status;
 PerlExtensionInit lxs_init;
 dTHX;

   lxs_init = getPerlExtensionRoutine(extensions);

   argc = GET_LENGTH(args);
   argv = characterVectorToArray(args, TRUE);


   status = perl_parse(interp, xs_init, argc, argv, (char **) NULL /* environment settings */);
   /* PL_exit_flags |= PERL_EXIT_DESTRUCT_END;  */

  if (status || SvTRUE(ERRSV)) {
    char tmp[5000] = "<no message>";

    if(SvTRUE(ERRSV)) {
      sprintf(tmp, "%s", SvPV(ERRSV, PL_na));
      sv_setpv(ERRSV,"");
    }
    PROBLEM "Error parsing Perl file %s: %s", argv[1], tmp
    ERROR;
  }   

  if(LOGICAL_DATA(run)[0]) {
    ans = NEW_INTEGER(1);
    INTEGER_DATA(ans)[0] =  perl_run(RS_perl);
    if (SvTRUE(ERRSV)) {
     char tmp[5000];

     sprintf(tmp, "%s", SvPV(ERRSV, PL_na));
     sv_setpv(ERRSV,"");
     PROBLEM "Error evaluating Perl file %s: %s", CHAR_DEREF(STRING_ELT(VECTOR_ELT(args, 1), 0)),
                                                   tmp
     ERROR;
  }   
  }

 return(ans);
}


SEXP
RS_loadModule(SEXP name, SEXP args, SEXP flags)
{

   return(NULL_USER_OBJECT);
}

/*
 Retrieve the value of a Perl variable, either as an array or as a regular
 scalar value.
*/
USER_OBJECT_
RS_PerlGet(USER_OBJECT_ var, USER_OBJECT_ rsAsArray, USER_OBJECT_ Interpreter)
{
 USER_OBJECT_ ans;
 UNUSED(PerlInterpreter *interp = RS_resolvePerlInterpreter(Interpreter));
 Rboolean asArray = LOGICAL_DATA(rsAsArray)[0];
 unsigned int depth = 1; /*XXX should allow caller to specify this. */
 dTHX;

 /* Need to add support for tables also. */
 if(asArray == FALSE) {
   SV* val = get_sv(CHAR_DEREF(STRING_ELT(var, 0)), FALSE);
   if(val == NULL) {
     PROBLEM "No such Perl variable `%s'",CHAR_DEREF(STRING_ELT(var, 0))     
     ERROR;
   }
   ans = fromPerl(val, TRUE);
 } else {
   AV* val = get_av(CHAR_DEREF(STRING_ELT(var, 0)), FALSE);
   ans = fromPerlAV(val, NULL, depth);
 }

return(ans);
}


/**
 Get the name from this object.
 If it is a string, use that.
 Otherwise, we expect it to be a PerlCodeReference and we look
 for its "name" element and use that.
 */
const char *
RPerl_getInternalName(USER_OBJECT_ name)
{
    if(IS_CHARACTER(name)) {
	return(CHAR_DEREF(STRING_ELT(name, 0)));
    } else {
         /* This should check we have an object of class PerlCodeReference. */
        USER_OBJECT_ names = GET_NAMES(name);
	int i, n;
        n = GET_LENGTH(names);
	for(i = 0; i < n; i++) {
	    if(strcmp(CHAR_DEREF(STRING_ELT(names, i)), "name") == 0)
		return(CHAR_DEREF(STRING_ELT(VECTOR_ELT(name, i), 0)));
	}
    }
    return("<unknown name?>");
}




/**

 This is the currently preferred version of invoking a Perl subroutine or method
 rather than the RS_PerlCall below. This first converts the R arguments to the Perl routine
 into Perl values and does this without entering the local stack.
 Then it pushes them onto the stack. This avoids opening the local stack and then
 potentially creating a call to Perl when, e.g., creating a reference. That seems to mess things
 up quite considerably.

  C-level entry point for the .Perl() function.
  Calls the Perl routine/method identified by the name argument.
  This is either a string or else a reference to a PerlCode object
  (e.g. retrieved from the R/S .PerlGetCode() function).
  If it is a method to be invoked, the refObj must be a PerlObjectReference
  obtained from an earlier call to .PerlNew() or some other function.
  The args value is an R/S list of the arguments specified in the .Perl call.
  These are converted to their Perl equivalents via the toPerl() routine.
  The convert argument is a logical value indicating whether the result
  should be converted to a regular R/S object or left as a Perl reference
  and a suitable R object returned.
  array is a logical value indicating whether the result should be
  treated as an array or a scalar. This is equivalent to the difference
  between  @x = foo(); and $x = foo(). In other words, the context of
  the call influences what type the result is.
 */
USER_OBJECT_
RS_PerlCallModified(USER_OBJECT_ name, USER_OBJECT_ args, USER_OBJECT_ convert, USER_OBJECT_ array, USER_OBJECT_ refObj, USER_OBJECT_ Interpreter)
{
 int i, n, numArgs, j;
 int perlReturnType;
 USER_OBJECT_ val, names;
 UNUSED(PerlInterpreter *interp = RS_resolvePerlInterpreter(Interpreter));
 Rboolean asMethod = FALSE;
 unsigned int doConvert = 1;
 SV **perlArgs;

 int callFlags = 0;

 dTHX;
 dSP;
 /* 
   We have a potential problem here in that if we get an error when creating
   these Perl values, we won't free the previously created values.
   We will have to smoothen out the details here.
  */

 if(GET_LENGTH(name) == 0) {
    PROBLEM "NULL or empty object passed as Perl method identifier"
    ERROR;
 }

 if(TYPEOF(convert) == LGLSXP || TYPEOF(convert) == INTSXP)
    doConvert = TYPEOF(convert) == LGLSXP ? LOGICAL_DATA(convert)[0] : INTEGER(convert)[0];


 n = numArgs = GET_LENGTH(args);
 perlArgs = (SV **) S_alloc(n, sizeof(SV*));
 for(i = 0 ; i < n ;i++) {  
  USER_OBJECT_ tmp = VECTOR_ELT(args, i);
  if(0 && GET_LENGTH(tmp) > 1) { /* This looks like complete garbage! */
    for(j = 0; j < GET_LENGTH(tmp) ; j++)  {
      perlArgs[i] = newSVpv(CHAR_DEREF(STRING_ELT(tmp, j)), 0);
    }
  } else {
      SV *s = toPerl(VECTOR_ELT(args, i), FALSE); /* Don't mess with the reference counts. We'll take care of it here.*/
      perlArgs[i] = s;
  }
 }


 ENTER;
 SAVETMPS;
 PUSHMARK(sp);

 perlReturnType = LOGICAL_DATA(array)[0] ? G_ARRAY : G_SCALAR; 
 callFlags = perlReturnType | G_EVAL  | G_KEEPERR;

 if(GET_LENGTH(refObj) > 0) {
   SV *el;
   if(IS_LOGICAL(refObj)) {
     asMethod = LOGICAL_DATA(refObj)[0];
   } else {
     el = getForeignPerlReference(refObj);
     XPUSHs(el);
     asMethod = TRUE;
   }
 }



 names = GET_NAMES(args);
 for(i = 0; i < n; i++) {
     const char *p;
      /* If an argument has a name, then push that name too. */
     if(GET_LENGTH(names) && (p = CHAR_DEREF(STRING_ELT(names, i))) && p[0]) {
       XPUSHs(sv_2mortal(newSVpv(p, 0)));
     }
     XPUSHs(sv_mortalcopy(perlArgs[i])); /*XPUSHs(sv_2mortal(perlArgs[i])); */
 }
 

 PUTBACK;

 if(asMethod) {
     n = call_method(CHAR_DEREF(STRING_ELT(name, 0)), callFlags);
 } else {

     if(!IS_CHARACTER(name)) {
	 SV *cv;
	 cv = getPerlCodeObject(name);

	 if(cv == NULL) {
	     PROBLEM "Non-code reference passed via .Perl. Need a sub-routine name or Code object."
		 ERROR;
	 }
	 n = call_sv(cv, callFlags);
     } else 
         n = call_pv(CHAR_DEREF(STRING_ELT(name, 0)), callFlags); 
 }


 SPAGAIN;

 if (SvTRUE(ERRSV)) {
  char tmp[5000];
  POPs;
 
  PUTBACK;
  FREETMPS;
  LEAVE;

  sprintf(tmp, "%s", SvPV(ERRSV, PL_na));
  sv_setpv(ERRSV,"");
  PROBLEM "Error calling Perl routine %s: %s", RPerl_getInternalName(name),
                                               tmp
  ERROR;
 }


 if(n > 0) {
   if(n == 1) {
      if(TYPEOF(convert) == LGLSXP || TYPEOF(convert) == INTSXP) {
         val = fromPerl(POPs, doConvert);
      } else
         val = directConvertFromPerl(POPs, convert);
   } else {
     /* Not obeying the convert here to put it into an array and leaving it as a reference. */

     PROTECT(val = NEW_LIST(n));
      for(i = n; i > 0 ; i--) {
        SET_VECTOR_ELT(val, i-1, fromPerl(POPs, doConvert));
      }
/*Causes references to be unlisted! */
       val = simplifyRList(val); 

     UNPROTECT(1);
   }
 } else 
      val = NULL_USER_OBJECT;

 PUTBACK;
 FREETMPS;
 LEAVE;


#if RSPERL_DEBUG
 for(i = 0; i < numArgs; i++) {
     int t;
     t = SvREFCNT(perlArgs[i]);
     fprintf(stderr, "Ref count %d) = %d\n", i, t);
 }
#endif

 return(val);
}


/*
  C-level entry point for the .Perl() function.
  Calls the Perl routine/method identified by the name argument.
  This is either a string or else a reference to a PerlCode object
  (e.g. retrieved from the R/S .PerlGetCode() function).
  If it is a method to be invoked, the refObj must be a PerlObjectReference
  obtained from an earlier call to .PerlNew() or some other function.
  The args value is an R/S list of the arguments specified in the .Perl call.
  These are converted to their Perl equivalents via the toPerl() routine.
  The convert argument is a logical value indicating whether the result
  should be converted to a regular R/S object or left as a Perl reference
  and a suitable R object returned.
  array is a logical value indicating whether the result should be
  treated as an array or a scalar. This is equivalent to the difference
  between  @x = foo(); and $x = foo(). In other words, the context of
  the call influences what type the result is.
 */
USER_OBJECT_
RS_PerlCall(USER_OBJECT_ name, USER_OBJECT_ args, USER_OBJECT_ convert, USER_OBJECT_ array, USER_OBJECT_ refObj, USER_OBJECT_ Interpreter)
{
 int i, n, j;
 int perlReturnType;
 USER_OBJECT_ val;
 UNUSED(PerlInterpreter *interp = RS_resolvePerlInterpreter(Interpreter));
 Rboolean asMethod = FALSE;
 Rboolean doConvert = LOGICAL_DATA(convert)[0];

 dTHX;
 dSP;

 ENTER;
 SAVETMPS;
 PUSHMARK(sp);

 perlReturnType = LOGICAL_DATA(array)[0] ? G_ARRAY : G_SCALAR; 

 if(GET_LENGTH(refObj) > 0) {
   SV *el;
   if(IS_LOGICAL(refObj)) {
     asMethod = LOGICAL_DATA(refObj)[0];
   } else {
     el = getForeignPerlReference(refObj);
     XPUSHs(el);
     asMethod = TRUE;
   }
 }

 n = GET_LENGTH(args);
 for(i = 0 ; i < n ;i++) {  
  USER_OBJECT_ tmp = VECTOR_ELT(args, i);
  if(GET_LENGTH(tmp) > 1) {
    for(j = 0; j < GET_LENGTH(tmp) ; j++)  {
      XPUSHs(newSVpv(CHAR_DEREF(STRING_ELT(tmp, j)), 0));
    }
  } else {
      SV *s = toPerl(tmp, TRUE);
      XPUSHs(s);
  }
 }

 PUTBACK;

if(asMethod) {
 n = call_method(CHAR_DEREF(STRING_ELT(name, 0)), perlReturnType | G_EVAL | G_KEEPERR);
}
else {
  if(!IS_CHARACTER(name)) {
    SV *cv;
      cv = getPerlCodeObject(name);
      if(cv == NULL) {
        PUTBACK;
	FREETMPS;
	LEAVE;

        PROBLEM "Non-code reference passed via .Perl. Need a sub-routine name or Code object."
	  ERROR;
      }
      n = call_sv(cv, perlReturnType | G_EVAL | G_KEEPERR);
  } else 
      n = call_pv(CHAR_DEREF(STRING_ELT(name, 0)), perlReturnType | G_EVAL | G_KEEPERR);
}

 if (SvTRUE(ERRSV)) {
  char tmp[5000];
  PUTBACK;
  FREETMPS;
  LEAVE;
 
   sprintf(tmp, "%s", SvPV(ERRSV, PL_na));
   sv_setpv(ERRSV,"");
   PROBLEM "Error calling Perl routine %s: %s", RPerl_getInternalName(name),
                                                 tmp
   ERROR;
 }

 SPAGAIN;

 if(n > 0) {
   if(n == 1)
     val = fromPerl(POPs, doConvert);
   else {
     PROTECT(val = NEW_LIST(n));
      for(i = n; i > 0 ; i--) {
        SET_VECTOR_ELT(val, i-1, fromPerl(POPs, LOGICAL_DATA(convert)[0]));
      }
      UNPROTECT(1);
   }
  } else 
      val = NULL_USER_OBJECT;

 PUTBACK;
 FREETMPS;
 LEAVE;

 return(val);
}



#ifdef USE_PERL_JOIN
/*
 An example of calling a Perl built-in -- join().
 This expects the separator as the first argument
 and a character vector of elements to concatenate,
 separated by the separator.
 This is the same as paste(els, sep=sep).
 */
USER_OBJECT_
RS_PerlJoin(USER_OBJECT_ sep, USER_OBJECT_ els)
{
 int n = GET_LENGTH(els), i;
 USER_OBJECT_ result;
 SV *targ ;
 SV *del;

 dTHX;
 dSP;

 dMARK;

 ENTER;
 SAVETMPS;
 PUSHMARK(sp);

 del = newSVpv(CHAR_DEREF(STRING_ELT(sep, 0)), 0);
 for(i = 0 ; i < n ;i++) {  
     XPUSHs(newSVpv(CHAR_DEREF(STRING_ELT(els, i)), 0));
 }

 PUTBACK;
 {
  targ = newSVpv("duncan",0);
 Perl_do_join(targ, del, MARK, SP);
 }
 SPAGAIN;

 result = fromPerl(targ, TRUE);

 PUTBACK;
 FREETMPS;
 LEAVE;
 
 return(result);
}
#endif

#ifdef USE_PERL_SPLIT
/*
 This doesn't work yet.
 */
USER_OBJECT_
RS_PerlSplit(USER_OBJECT_ pat, USER_OBJECT_ str)
{
 SV *ppat, *pstr, *n;
 dTHX;
 dSP;
 dMARK;

 ENTER;
 SAVETMPS;
 PUSHMARK(sp);

  n = newSViv(100);
  XPUSHs(n);
  ppat = newSVpv(CHAR_DEREF(STRING_ELT(pat, 0)), 0);
  XPUSHs(ppat);
  pstr = newSVpv(CHAR_DEREF(STRING_ELT(str, 0)), 0);
  XPUSHs(pstr);

  PUTBACK;

  Perl_pp_split();

 SPAGAIN;
 PUTBACK;
 FREETMPS;
 LEAVE;

 return(NULL_USER_OBJECT);
}
#endif

USER_OBJECT_
RS_PerlPackage(USER_OBJECT_ pkgName)
{
  dTHX;
  /* SV *sv = newSVpv(CHAR_DEREF(STRING_ELT(pkgName, 0)), 0); */
  require_pv(CHAR_DEREF(STRING_ELT(pkgName, 0)));

  return(NULL_USER_OBJECT);
}
