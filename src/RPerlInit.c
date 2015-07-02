/*
 The routines in this file control the creation and destruction
 of potentially multiple Perl interpreters and also provide
 entry points to query these C-level data structures from R/S
 functions.
 Basically, we maintain a linked list of Perl interpreters and
 identifiers. The identifiers are simple increasing numbers
 indicating the interpreter instance within this (R) session.
 
 */
#include "RSPerl.h"

#include <unistd.h> /* For getpid(). */

typedef struct _PerlInterpreterElement {

  PerlInterpreter *interpreter;  
  int id;
  struct _PerlInterpreterElement *next;

} PerlInterpreterElement;


 int PerlInterpreterCount = 0;
 PerlInterpreterElement *PerlInterpreterList = NULL;
 
 PerlInterpreter *RS_perl;  /***    The Perl interpreter    ***/

 Rboolean REmbeddedInPerl = FALSE;

PerlInterpreterElement * registerPerlInterpreter(PerlInterpreter *interpreter);
int unregisterPerlInterpreter(PerlInterpreter *interpreter);

USER_OBJECT_ createRSPerlInterpreterRef(PerlInterpreterElement *el);

#include "Utils.h"

void xs_init _((void));

#ifdef NO_XS_GENERATED
void xs_init _((void))
{

}
#endif

/*
 Create a Perl interpreter, initializing it using the command line
 argments in `args' and an optional C routine given by name in rsExtensions.
 This is for loading the C code for the different modules, etc.
 If the logical value run is TRUE,  the interpreter is activated.
 */
USER_OBJECT_
RS_InitPerl(USER_OBJECT_ args, USER_OBJECT_ rsExtensions, USER_OBJECT_ run)
{
 int argc;
 char **argv;
 PerlExtensionInit lxs_init;
 PerlInterpreter  *interpreter;
 USER_OBJECT_ ans;
 PerlInterpreterElement *el;


   argc = GET_LENGTH(args);
   argv =  characterVectorToArray(args, TRUE);
     
   lxs_init = getPerlExtensionRoutine(rsExtensions);
   if(lxs_init == NULL) {
     lxs_init = (PerlExtensionInit) xs_init;
   }

   interpreter = perl_alloc();
   perl_construct(interpreter);

   perl_parse(interpreter, lxs_init, argc, argv, (char **)NULL);
   if(1 || LOGICAL_DATA(run)[0])
     perl_run(interpreter);

     /* Make this the active interpreter. */
   RS_perl = interpreter;

   el = registerPerlInterpreter(interpreter);
   ans = createRSPerlInterpreterRef(el);

   /*   perl_atexit(my_exit_jump, NULL); */

 return(ans);
}


void
setPerlInterpreter(PerlInterpreter *p)
{
	RS_perl = p;
}

void
setREmbeddedInPerl(Rboolean val)
{
	REmbeddedInPerl = val;
}



/*
  Adds the specific Perl interpreter to the linked
  list of interpreters.
 */
PerlInterpreterElement *
registerPerlInterpreter(PerlInterpreter *interpreter)
{
 PerlInterpreterElement *el;

  PerlInterpreterCount++;
  el = (PerlInterpreterElement *)calloc(1,sizeof(PerlInterpreterElement));
  el->interpreter = interpreter;
  el->id = PerlInterpreterCount;

  if(PerlInterpreterList) {
    el->next = PerlInterpreterList;
    PerlInterpreterList = el;
  } else
    PerlInterpreterList = el;

  if(!RS_perl)
     RS_perl = interpreter;

 return(el);
}

USER_OBJECT_
RS_getPerlInterpreter(USER_OBJECT_ all)
{
 USER_OBJECT_ ans;
 PerlInterpreterElement *el;   
  if(LOGICAL_DATA(all)[0]) {
    int n = 0;
    el = PerlInterpreterList;
    while(el) {
      n++;
      el = el->next;
    }
    PROTECT(ans = NEW_LIST(n));
    n = 0;
    el = PerlInterpreterList;
    while(el) {
      SET_VECTOR_ELT(ans, n, createRSPerlInterpreterRef(el));
      n++;
      el = el->next;
    }
    UNPROTECT(1);
  } else {
    el = PerlInterpreterList;
    while(el) {
      if(el->interpreter == RS_perl)
	break;
      el = el->next;
    }

    if(el== NULL)
      return(NULL_USER_OBJECT);

    ans = createRSPerlInterpreterRef(el);
  }

  return(ans);
}

USER_OBJECT_
createRSPerlInterpreterRef(PerlInterpreterElement *el)
{
 USER_OBJECT_ ans, klass, names, tmp;

  PROTECT(ans = NEW_LIST(2));
  PROTECT(klass = NEW_CHARACTER(1));
  PROTECT(names = NEW_CHARACTER(2));

  SET_VECTOR_ELT(ans, 0, tmp=NEW_INTEGER(1));
   INTEGER_DATA(tmp)[0] = el->id;
  SET_STRING_ELT(names, 0, COPY_TO_USER_STRING("id"));

  SET_VECTOR_ELT(ans, 1, tmp=NEW_NUMERIC(1));
   NUMERIC_DATA(tmp)[0] = getpid();
  SET_STRING_ELT(names, 1, COPY_TO_USER_STRING("pid"));
  
  SET_STRING_ELT(klass, 0, COPY_TO_USER_STRING("PerlInterpreter"));
  SET_CLASS(ans, klass);
  UNPROTECT(3);

  return(ans);
}

/*
 Resolves the actual PerlInterpreter based
 on an R/S object which contains its identifier.
 */
PerlInterpreter *
RS_resolvePerlInterpreter(USER_OBJECT_ perl)
{
  int id;
  PerlInterpreterElement *el;

  if(!RS_perl && !REmbeddedInPerl) {
    /*XXX Need to make certain this still works when calling R from Perl. */
    PROBLEM "The Perl interpreter has not been initialized. Use .PerlInit() first."
    ERROR;
  }


  if(GET_LENGTH(perl) == 0) {
    return(RS_perl);
  }

  id = INTEGER_DATA(VECTOR_ELT(perl, 0))[0];
  el = PerlInterpreterList;
  while(el) {
    if(el->id == id) {
      return(el->interpreter);
    }
    el = el->next;
  }

  return(NULL);
}

/*
  Terminate a Perl interpreter and unregister it.
 */

USER_OBJECT_
RS_FinishPerl(USER_OBJECT_ perl)
{
  PerlInterpreter *interpreter;
  USER_OBJECT_ ans;
  PROTECT(ans = NEW_LOGICAL(1));

  interpreter = RS_resolvePerlInterpreter(perl);
  if(interpreter) {
    LOGICAL_DATA(ans)[0] = TRUE;
    unregisterPerlInterpreter(interpreter);
    perl_destruct(interpreter);
    perl_free(interpreter);
  }

   UNPROTECT(1);

 return(ans);
}

int 
unregisterPerlInterpreter(PerlInterpreter *interpreter)
{
  int which = 0;
  PerlInterpreterElement *el, *prev;
  prev = NULL;
  el = PerlInterpreterList;
  while(el) {
    if(el->interpreter == interpreter) {
	 if(prev)
  	   prev->next = el->next;
      else
	   PerlInterpreterList = el->next;

	  break;
    }
    prev = el;
    el = el->next;
    which++;
  }

 return(which);
}

PerlExtensionInit
getPerlExtensionRoutine(USER_OBJECT_ rsExtensions)
{
#ifdef _R_
 void* R_FindSymbol(char const *, char const *);
#endif
 PerlExtensionInit lxs_init = NULL;


   if(GET_LENGTH(rsExtensions) > 0) {
     /* */
    
#ifdef _R_
   lxs_init = (PerlExtensionInit) R_FindSymbol(CHAR_DEREF(STRING_ELT(rsExtensions,0)), GET_LENGTH(rsExtensions) > 1 ? CHAR_DEREF(STRING_ELT(rsExtensions,1)) : NULL);
#else
    lxs_init = (PerlExtensionInit) dlsym(NULL, CHAR_DEREF(STRING_ELT(rsExtensions,0)));
#endif    
   } else {
    lxs_init = (PerlExtensionInit) xs_init; /* Have to be careful to get the right thing. */
   }

 return(lxs_init);
}
