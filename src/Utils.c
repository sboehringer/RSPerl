#include "RSCommon.h"

char **
characterVectorToNullTerminatedArray(USER_OBJECT_ obj, Rboolean copyElements) 
{
 int n, i;
 char **tmp;
 USER_OBJECT_ ch;
  PROTECT(ch = AS_CHARACTER(obj));

 n = GET_LENGTH(ch);
 if(n < 1) {
   UNPROTECT(1);
   return((char  **)NULL);
 }

 n++;
#ifdef _R_
 tmp = (char **)R_alloc(n, sizeof(char *));
#else
 tmp = Salloc(n, char *);
#endif

 for(i = 0; i < n; i++) {
   /* do not use COPY_TO_USER_STRING */
   if(copyElements) {
     /* */
#ifdef _R_
      tmp[i] = (char*)R_alloc(strlen(CHAR_DEREF(STRING_ELT(ch, i)))+1, sizeof(char));
#else
      tmp[i] = Salloc(strlen(CHAR_DEREF(STRING_ELT(ch, i)))+1, char);
#endif
      strcpy(tmp[i],  CHAR_DEREF(STRING_ELT(ch, i)));
   } else  {
      tmp[i] = CHAR_DEREF(STRING_ELT(ch, i));
   }
 }
 tmp[n-1] = NULL;

 UNPROTECT(1);

return(tmp);
}



char **
characterVectorToArray(USER_OBJECT_ obj, Rboolean copyElements) 
{
 int n, i;
 char **tmp;
 USER_OBJECT_ ch;
  PROTECT(ch = AS_CHARACTER(obj));

 n = GET_LENGTH(ch);
 if(n < 1) {
   UNPROTECT(1);
   return((char **)NULL);
 }

#ifdef _R_
 tmp = (char **)R_alloc(n, sizeof(char *));
#else
 tmp = Salloc(n, char *);
#endif

 for(i = 0; i < n; i++) {
   /* do not use COPY_TO_USER_STRING */
   if(copyElements) {
     /* */
#ifdef _R_
      tmp[i] = (char*)R_alloc(strlen(CHAR_DEREF(STRING_ELT(ch, i)))+1, sizeof(char));
#else
      tmp[i] = Salloc(strlen(CHAR_DEREF(STRING_ELT(ch, i)))+1, char);
#endif
      strcpy(tmp[i],  CHAR_DEREF(STRING_ELT(ch, i)));
   } else  {
      tmp[i] = CHAR_DEREF(STRING_ELT(ch, i));
   }
 }

 UNPROTECT(1);

return(tmp);
}

void
my_exit_jump(void *ptr)
{
  fprintf(stderr, "In local my_exit_jump\n");
  PROBLEM "major error in Perl interpreter."
      ERROR;
}

#if 0
void
Perl_my_failure_exit(pTHX)
{
 PROBLEM "major error in Perl interpreter."
 ERROR;
}
#endif

