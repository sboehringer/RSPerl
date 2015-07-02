#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "RSCommon.h"
#include "ForeignReference.h"
#include "Converters.h"

static int RPerlDebug = 0;

char *argv[] = {"REmbeddedPerl", "--silent"};

Rboolean
isRPrimitive(SEXP val, SEXPTYPE *type)
{
 Rboolean is = FALSE;

 if(GET_LENGTH(GET_DIM(val))) {
  return(FALSE);
 }

 if(GET_LENGTH(GET_CLASS(val))) {
  return(FALSE);
 }
 
  *type = TYPEOF(val); 
 switch(*type) {
   case REALSXP:
   case LGLSXP:
   case STRSXP:
   case INTSXP:
     is = TRUE;
   default:
     break;
 }
/* if(is == TRUE && type) */

 return(is);
}

USER_OBJECT_
getFunctionId(SV *tmp, char **funcName)
{
 USER_OBJECT_ fun = NULL;
       if(sv_isobject(tmp)) {
        if(sv_derived_from(tmp, "RNamedFunctionReference")) {
           tmp = RPerl_getReferenceName(tmp);
           *funcName = SvPV(tmp, PL_na);
           fun = Rf_install((char *)funcName);
        } else if(sv_derived_from(tmp, "RReferences")) {
           fun = RPerl_getProxyValue(tmp);
           *funcName = "R function reference";
        } else {
          fprintf(stderr, "Incorrect reference type of object passed as first arg to R::call()\n");fflush(stderr);
          return(NULL);
        }
       } else if(SvPOK(tmp)) {
 	 char *name;
	 name = SvPV_nolen(tmp);
    /*
         name = SvPV(tmp, SvCUR(tmp)); 
    */
         if(!name) {
          fprintf(stderr, "Couldn't get name from Perl string\n");fflush(stderr);          
           return(NULL);
         }

         if(funcName)
   	    *funcName = name;
         fun = Rf_install((char *)name);
       } else {
         /* Really need a string here. So bail with an error. */
         fprintf(stderr, "Incorrect type of object passed as first arg to R::call()\n");fflush(stderr);
         return(NULL);
       }

   return(fun);
}



/*
 R_call is a general .R()-like function for calling R functions
 from Perl. An arbitray number of arguments can be passed.
*/
MODULE = R		PACKAGE = R		PREFIX=R_


PROTOTYPES: ENABLE



SV *
R_call(...)
      PREINIT:
      char *funcName = "?";
      int numArgs = 2;
      int errorOccurred;
      SV  *result, *sv, *tmp;
      USER_OBJECT_ e, fun, val;
      int i;
      SEXPTYPE Rtype;
      Rboolean addLocal;

      PPCODE:
       
       numArgs = (items);

       tmp = ST(0);

       fun = getFunctionId(tmp, &funcName);
       if(fun == NULL || GET_LENGTH(fun) == 0) {
         fprintf(stderr, "Couldn't find function to be called\n");fflush(stderr);
         /*XXX Should we put an undef on the stack. */
         return;
       }

       PROTECT(fun);

       if(RPerlDebug)
        fprintf(stderr, "Calling R function name `%s', # arguments: %d\n", funcName, numArgs);fflush(stderr);

       PROTECT(e = allocVector(LANGSXP, numArgs));
       SETCAR(e, fun);

       if(numArgs > 1) {
       	 svtype type;
         SEXP next = CDR(e), arg;

         for(i = 1; i < numArgs ; i++) {
          tmp = ST(i);
          type = SvTYPE(tmp);
          arg = NULL_USER_OBJECT;

          if(RPerlDebug)
             fprintf(stderr, "%d) Arg type %d\n", i, type);fflush(stderr);

          if(tmp == &PL_sv_undef) {
             arg = NULL_USER_OBJECT;
          } else if (sv_isa(tmp, "RReferences")) {
             arg = RPerl_getProxyValue(tmp);
          } else if(SvROK(tmp)) {
             if(RPerlDebug)
               fprintf(stderr, "Got a reference to a value %d\n", SvTYPE(SvRV(tmp)));fflush(stderr);
           #  arg = fromPerl(SvRV(tmp), TRUE);
             arg = fromPerl(tmp, TRUE);
       	  }  else if(SvIOK(tmp)){
             PROTECT(arg = NEW_INTEGER(1));
               INTEGER_DATA(arg)[0] = SvIV(tmp);
             UNPROTECT(1);    
          } else if(SvPOK(tmp)){
             PROTECT(arg = NEW_CHARACTER(1));
               SET_STRING_ELT(arg, 0, COPY_TO_USER_STRING(SvPV(tmp, PL_na)));
             UNPROTECT(1);    
          } else if(SvNOK(tmp)) {
             PROTECT(arg = NEW_NUMERIC(1));
               NUMERIC_DATA(arg)[0] = SvNV(tmp);
             UNPROTECT(1);    
          } else {
fprintf(stderr, "Didn't convert Perl argument %d\n", i);fflush(stderr);
          }
          SETCAR(next, arg);        
          next = CDR(next);
         }
       }

      if(RPerlDebug) {
        fprintf(stderr, "Calling R\n");fflush(stderr);
        Rf_PrintValue(e);
      }

      val = R_tryEval(e, R_GlobalEnv, &errorOccurred);
      if(errorOccurred) {
        fprintf(stderr, "Caught error in R::call()\n");fflush(stderr);
        UNPROTECT(2);
         /*XXX Throw error here! */
        return;
      }

      PROTECT(val);

      if(RPerlDebug)  {
        fprintf(stderr, "Performed the call, result has length %d\n", GET_LENGTH(val));fflush(stderr);
      }

      if(GIMME_V == G_VOID || val == NULL_USER_OBJECT || GET_LENGTH(val) == 0) {
         XPUSHs(&PL_sv_undef);
      } else if(isRPrimitive(val, &Rtype)) {
        EXTEND(SP,GET_LENGTH(val));
        if(RPerlDebug)  {
           fprintf(stderr, "Primitive, R type: %d, of length %d\n", (int)Rtype, GET_LENGTH(val));fflush(stderr);
           Rf_PrintValue(val);
        }

        for(i = 0; i < GET_LENGTH(val); i++) {
           sv = NULL;
           switch(Rtype) {
    	     case STRSXP:
    		sv = newSVpv(CHAR(STRING_ELT(val, i)), 0);
    	     break;
    	     case LGLSXP:
    		sv = newSViv(LOGICAL_DATA(val)[i]);
    	     break;
    	     case INTSXP:
    		sv = newSViv(INTEGER_DATA(val)[i]);
    	     break;
    	     case REALSXP:
    		sv = newSVnv(NUMERIC_DATA(val)[i]);
    	     break;
             default:
               sv = NULL;
           }
           if(sv) {
              PUSHs(sv_2mortal(sv));
           }
        }
      } else {
	 result = userLevelConversionToPerl(val);
	 if(result == NULL)
	     result = RPerl_createRProxy(val);
         XPUSHs(sv_2mortal(result));
      }

       UNPROTECT(3);

SV *
R_callWithNames(func, argTable)
      SV *func
      SV *argTable;
      PREINIT:
          /* 
           Allows an R function to be called with named arguments.
           The input
          */
      char *funcName; 
      int numArgs=0;
      int errorOccurred;
      SV  *result, *sv;
      USER_OBJECT_ e, val;
      int i;
      I32 len;
      SEXPTYPE Rtype;
      Rboolean addLocal;
      svtype argType;
      PPCODE:

      if(SvROK(argTable))
         argTable = SvRV(argTable);

       argType = SvTYPE(argTable);

       numArgs = hv_iterinit((HV*)argTable);

       if(RPerlDebug)
   	   fprintf(stderr, "# of named arguments %d\n", numArgs);fflush(stderr);

       PROTECT(e = allocVector(LANGSXP, numArgs+1));

       SETCAR(e, getFunctionId(func, &funcName));

       if(numArgs > 0) {
       	 SV *tmp;
       	 svtype type;
         char *key;
         SEXP next = CDR(e), arg;

         for(i = 0; i < numArgs ; i++) {
	   Rboolean doUnprotect = 1;
           tmp = hv_iternextsv((HV*)argTable, &key, &len);
           type = SvTYPE(tmp);

           arg = NULL_USER_OBJECT;
	   doUnprotect = 1; 

           if(RPerlDebug)
             fprintf(stderr, "%d) %s  Arg type %d\n", i, key, type);fflush(stderr);
   
          if (sv_isa(tmp, "RReferences"))  {
            arg = RPerl_getProxyValue(tmp);
            doUnprotect = 0;
          } else if(tmp == &PL_sv_undef || !SvOK(tmp)) { /* &PL_sv_undef undefined */
	     doUnprotect = 0;
          } else if (SvROK(tmp)) {
            if(RPerlDebug)
              fprintf(stderr, "Got a reference to a value %d\n", (int) SvTYPE(SvRV(tmp)));fflush(stderr);
            arg = fromPerl(tmp, TRUE); 
	    doUnprotect = 0;	
       	  }  else if(SvIOK(tmp)){
             PROTECT(arg = NEW_INTEGER(1));
             INTEGER_DATA(arg)[0] = SvIV(tmp);
          } else if(SvPOK(tmp)){
             PROTECT(arg = NEW_CHARACTER(1));
             SET_STRING_ELT(arg, 0, COPY_TO_USER_STRING(SvPV(tmp, PL_na)));
          } else if(SvNOK(tmp)){
             PROTECT(arg = NEW_NUMERIC(1));
             NUMERIC_DATA(arg)[0] = SvNV(tmp);
          } else {
             doUnprotect = 0;
          }
          

          SETCAR(next, arg);        
          if(key && key[0])
             SET_TAG(next, Rf_install(key));

          if(doUnprotect)
             UNPROTECT(1);
          next = CDR(next);
         }
       }


      if(RPerlDebug)
          Rf_PrintValue(e);
      val = R_tryEval(e, R_GlobalEnv, &errorOccurred);
      if(errorOccurred) {
        UNPROTECT(1);
         /*XXX Throw error here! */
        return;
      }
      PROTECT(val);

      if(GIMME_V == G_VOID || val == NULL_USER_OBJECT || GET_LENGTH(val) == 0) {
         XPUSHs(&PL_sv_undef);
      } else if(isRPrimitive(val, &Rtype)) {
        EXTEND(SP,GET_LENGTH(val));
        for(i = 0; i < GET_LENGTH(val); i++) {
           switch(Rtype) {
    	     case STRSXP:
    		sv = newSVpv(CHAR(STRING_ELT(val, i)), 0);
    	     break;
    	     case LGLSXP:
    		sv = newSViv(LOGICAL_DATA(val)[i]);
    	     break;
    	     case INTSXP:
    		sv = newSViv(INTEGER_DATA(val)[i]);
    	     break;
    	     case REALSXP:
    		sv = newSVnv(NUMERIC_DATA(val)[i]);
    	     break;
             default:
               sv = NULL;
           }
           if(sv)
              XPUSHs(sv_2mortal(sv));
        }
      } else {
	 result = userLevelConversionToPerl(val);
	 if(result == NULL) {
           /* Rf_PrintValue(val) ; XXX */
           result = RPerl_createRProxy(val);
         }
         XPUSHs(sv_2mortal(result));
      }

       UNPROTECT(2);




#ifdef WITH_R_IN_PERL

void
initRSession(...)
  PREINIT:
   char *defaultArgs[] = {"REmbeddedPerl"};
   char **args;
   int numArgs, i;
  PPCODE:
  /* We should check that we haven't started this already. */
      numArgs = (items);
      if(numArgs > 0) {
        args = (char **)calloc(numArgs + 1, sizeof(char *));
        args[0] = strdup("REmbeddedPerl");
        for(i = 0; i < numArgs; i++) {
          args[i+1] = strdup(SvPV(ST(i), PL_na));
        }
        numArgs++;
      } else {
        numArgs = sizeof(defaultArgs)/sizeof(defaultArgs[0]);
        args = (char **)calloc(numArgs, sizeof(char *));
        for(i = 0; i < numArgs; i++) {
          args[i] = strdup(defaultArgs[i]);
        }
      }
      Rf_initEmbeddedR(numArgs, args);
      /* setREmbeddedInPerl((Rboolean) 1); */

#else

void
initRSession(...)
  PPCODE:

#endif


SV *
R_eval(cmd)
      char *cmd;

      PREINIT:

         SEXPTYPE Rtype;
         SV  *result, *sv;
         int i;
         USER_OBJECT_ e, tmp, val;
         int errorOccurred;

      PPCODE:
    
      PROTECT(e = allocVector(LANGSXP, 2));
      SETCAR(e, Rf_install("parseEval"));
      SETCAR(CDR(e), tmp = NEW_CHARACTER(1));
      SET_STRING_ELT(tmp, 0, COPY_TO_USER_STRING(cmd));

      if(RPerlDebug) {
        fprintf(stderr, "Evaluating command %s\n", cmd); fflush(stderr);
        Rf_PrintValue(e);
      }

      val = R_tryEval(e, R_GlobalEnv, &errorOccurred);
      if(errorOccurred) {
        UNPROTECT(1);
         /*XXX Throw error here! */
        return;
      }
      PROTECT(val);
      if(RPerlDebug) {
        fprintf(stderr, "Got the answer\n"); fflush(stderr);
        Rf_PrintValue(val);
      }
 
      if(GIMME_V == G_VOID || val == NULL_USER_OBJECT || GET_LENGTH(val) == 0) {
         XPUSHs(&PL_sv_undef);
      } else if(isRPrimitive(val, &Rtype)) {
        EXTEND(SP,GET_LENGTH(val));
      if(RPerlDebug) {
       fprintf(stderr, "Converting R primitive type to Perl: len = %d, type = %d\n",GET_LENGTH(val), Rtype);fflush(stderr); 
      }
        for(i = 0; i < GET_LENGTH(val); i++) {
           switch(Rtype) {
    	     case STRSXP:
    		sv = newSVpv(CHAR(STRING_ELT(val, i)), 0);
    	     break;
    	     case LGLSXP:
    		sv = newSViv(LOGICAL_DATA(val)[i]);
    	     break;
    	     case INTSXP:
    		sv = newSViv(INTEGER_DATA(val)[i]);
    	     break;
    	     case REALSXP:
    		sv = newSVnv(NUMERIC_DATA(val)[i]);
    	     break;
             default:
               sv = NULL;
           }
           if(sv)
              XPUSHs(sv_2mortal(sv));
        }
      } else {
	 result = userLevelConversionToPerl(val);
	 if(result == NULL)
           result = RPerl_createRProxy(val);
         XPUSHs(sv_2mortal(result));
      }
      
      UNPROTECT(2);





int
setConverter(match, converter, desc, toPerl)
	SV *match
	SV *converter
	char *desc
	int toPerl
	PREINIT:
	int autoArray = 1, index;
	PPCODE:
	  index = addPerlConverterRoutine(match, converter, toPerl, desc, autoArray);
	  PUSHi(sv_2mortal(newSViv(index)));




int
deleteRReference(ref)
	SV *ref
	PREINIT:
	int ok;
	PPCODE:
	  ok = RPerl_discardRProxy(ref);
	  PUSHi(sv_2mortal(newSViv(ok)));




SV *
R_setDebug(n)
      int n
      PPCODE:
         RPerlDebug = n;
         XPUSHs(sv_2mortal(newSViv(RPerlDebug)));




SV *
R_library(libName)
      char *libName;

      PREINIT:
      USER_OBJECT_ e, tmp;
      SV *sv;
      int errorOccurred;

      PPCODE:
       PROTECT(e = allocVector(LANGSXP, 2));
       SETCAR(e, Rf_install("library"));
       SETCAR(CDR(e), tmp = NEW_CHARACTER(1));
       SET_STRING_ELT(tmp, 0, COPY_TO_USER_STRING(libName));
       R_tryEval(e, R_GlobalEnv, &errorOccurred);
       UNPROTECT(1);
       sv = newSViv(errorOccurred == 0);      
       XPUSHs(sv_2mortal(sv));





double *
R_rnorm(n)
      int n
      PREINIT:
      SEXP in, out, e, fun;
      int i;
      PPCODE:
       PROTECT(in = NEW_INTEGER(1));
       INTEGER_DATA(in)[0] = n;
       PROTECT(e = allocVector(LANGSXP,2));
       PROTECT(fun = Rf_findFun(Rf_install("rnorm"),  R_GlobalEnv));
        SETCAR(e, fun);
        SETCAR(CDR(e), in);
        out = eval(e, R_GlobalEnv);
        EXTEND(SP, n);
        for(i = 0; i < n; i++)
          PUSHs(sv_2mortal(newSVnv(NUMERIC_DATA(out)[i])));

