#include "UserConverters.h"

typedef RSFromPerlConverter RSFromTargetConverter;
typedef RSToPerlConverter   RSToTargetConverter;

RSFromTargetConverter *FromTargetConverters;
RSToTargetConverter   *ToTargetConverters;

int addToTargetConverter(RSToTargetConverter *cvt);

#define fromPerlConverterDescription fromTargetConverterDescription
char *fromTargetConverterDescription(RSFromTargetConverter *cvt);

RSFromTargetConverter *
removeFromTargetConverterByIndex(int which)
{
 int ctr = 0;
 RSFromTargetConverter *tmp, *prev = NULL;
   tmp = FromTargetConverters;

   if(which == 0) {
       tmp = FromTargetConverters;
       FromTargetConverters = FromTargetConverters->next;
       return(tmp);
   }
 
   while(tmp != NULL && ctr++ < which) {
      prev = tmp;
      tmp = tmp->next;
   }

   if(tmp == NULL)
      return((RSFromTargetConverter*) NULL);

     /* Now drop this element. */
   prev->next = tmp->next;

 return(tmp);
}


RSFromTargetConverter *
removeFromTargetConverterByDescription(const char *desc, int *which)
{
 int ctr = 0;
 RSFromTargetConverter *tmp, *prev = NULL;
 char *tmpDesc; 
   tmp = FromTargetConverters;

   while(tmp != NULL) {
      tmpDesc = fromPerlConverterDescription(tmp);
#if 0
 fprintf(stderr,"Checking element %s\n", tmpDesc);fflush(stderr);         
#endif
      if(tmpDesc != NULL && strcmp(tmpDesc, desc) ==0) {
             /* Now drop this element. */
        if(prev)
          prev->next = tmp->next;
        else
          FromTargetConverters = tmp->next;

        if(which)
          *which = ctr;
        return(tmp);
      }
      prev = tmp;
      tmp = tmp->next;
      ctr++;
   }

    return((RSFromTargetConverter*) NULL);
}


USER_OBJECT_ 
RPerl(removeConverter)(USER_OBJECT_ id, USER_OBJECT_ fromPerl, USER_OBJECT_ useDescription)
{
  USER_OBJECT_ ans;
  int ok = -1;
  int which = -1;
  const char *desc = NULL;

   if(LOGICAL_DATA(useDescription)[0]) {
     desc = CHAR_DEREF(STRING_ELT(id, 0));       
   } else
     which = INTEGER_DATA(id)[0];
  
  PROTECT(ans = NEW_INTEGER(1));  
  if(LOGICAL_DATA(fromPerl)[0] != 0) {
     RSFromTargetConverter *el;
      if(desc != NULL) {
        el = removeFromTargetConverterByDescription(desc, &ok);
      } else
        el = removeFromTargetConverterByIndex(which);

     if(el != NULL) {
       USER_OBJECT_ names;
       char *tmp;
         PROTECT(names = NEW_CHARACTER(1));
           tmp = fromPerlConverterDescription(el);
           if(tmp != NULL)
             SET_STRING_ELT(names, 0, COPY_TO_USER_STRING(tmp));
           SET_NAMES(ans, names);
         UNPROTECT(1);
       free(el);
       if(desc == NULL)
         ok = which;       
     }
  } else {
     PROBLEM "Removing a from R to Perl converter not supported yet!"
     ERROR;
  }

  INTEGER_DATA(ans)[0] = ok;
  UNPROTECT(1);
  
  return(ans);
}


int
getNumConverters(int which)
{
 int ctr = 0;
 if(which == 0) {
      RSFromTargetConverter *tmp = FromTargetConverters;
      while(tmp) {
        ctr++;
        tmp = tmp->next;
      }
 } else {
      RSToTargetConverter *tmp = ToTargetConverters;
      while(tmp) {
        ctr++;
        tmp = tmp->next;
      }
 }

 return(ctr);
}

USER_OBJECT_
RPerl(getNumConverters)(USER_OBJECT_ which)
{
 USER_OBJECT_ ans;
  ans = NEW_INTEGER(1);
 
  INTEGER_DATA(ans)[0] = getNumConverters(LOGICAL_DATA(which)[0]);
 return(ans);
}

USER_OBJECT_
RPerl(getConverterDescriptions)(USER_OBJECT_ which)
{
  int type = LOGICAL_DATA(which)[0];
  int n, i;
  const char *d;
  USER_OBJECT_ ans;
  RSFromTargetConverter *tmp0 = FromTargetConverters;
  RSToTargetConverter *tmp1 = ToTargetConverters;
  
  n = getNumConverters(type);

  PROTECT(ans = NEW_CHARACTER(n));
   for(i = 0; i < n ; i++) {
    if(type == 0) {
      d = tmp0->description;
      if(!d) {
         d = fromTargetConverterDescription(tmp0);
      }
      tmp0 = tmp0->next;      
    } else {
      d = tmp1->description;
      tmp1 = tmp1->next;
    }
    
    if(d)    
     SET_STRING_ELT(ans, i, COPY_TO_USER_STRING(d));
   }

  UNPROTECT(1);

 return(ans); 
}    


char *
fromTargetConverterDescription(RSFromTargetConverter *cvt)
{
  char *ans = NULL;

  if(cvt->description)
    return(cvt->description);

  return(ans);
}    



/*
 registerConverter
 */


int
addFromTargetConverter(RSFromTargetConverter *el)
{
 int ctr = 0;
  el->next = NULL;
  if(FromTargetConverters == NULL) {
    FromTargetConverters = el;
  } else { 
    RSFromTargetConverter *tmp;
    tmp = FromTargetConverters;
    while(tmp->next) {
     ctr++;
     tmp = tmp->next;
    }

    tmp->next = el;
    ctr++;
  }

 return(ctr);
}


RSFromPerlConverter * 
addFromPerlConverterInfo(FromPerlConverterMatch match, FromPerlConverter converter, 
                            Rboolean autoArray, void *userData, char *description, int *index)
{
 int pos;
 RSFromTargetConverter *cvt = (RSFromTargetConverter*) malloc(sizeof(RSFromTargetConverter)); 
  cvt->match = match;
  cvt->converter = converter;
  cvt->autoArray = autoArray;
  cvt->userData = userData;
  cvt->description = description;
  cvt->next = NULL;

  pos = addFromTargetConverter(cvt);
  if(index)
    *index = pos;

 return(cvt);
}



RSToTargetConverter *
addToTargetConverterInfo(ToTargetConverterMatch match, ToTargetConverter converter, Rboolean autoArray, void *userData, char *description, int *index)
{
 int pos;
 RSToTargetConverter *cvt = (RSToTargetConverter*) malloc(sizeof(RSToTargetConverter)); 
  cvt->match = match;
  cvt->converter = converter;
  cvt->autoArray = autoArray;
  cvt->userData = userData;
  cvt->description = description;
  cvt->next = NULL;

  pos = addToTargetConverter(cvt);
  if(index)
    *index = pos;

 return(cvt);
}

int
addToTargetConverter(RSToTargetConverter *cvt)
{
  int ctr = 0;
  RSToTargetConverter *tmp = ToTargetConverters;

  cvt->next = NULL;
  if(tmp == NULL) {
     ToTargetConverters = cvt;
  } else {
    while(tmp->next) {
       ctr++;
       tmp = tmp->next;
    }
    tmp->next = cvt;
  }      
  
  return(ctr);
}


