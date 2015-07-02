#ifndef RSPYTHON_USER_CONVERTERS_H
#define RSPYTHON_USER_CONVERTERS_H

#define RPerl(x) RPerl_##x

#include "RSPerl.h"

#include "Converters.h"

/* #include "RPythonModule.h" */
/*
  The following are related to User-level or extensible converters.
  They are modelled on and copied from the Converters.cweb file in the 
  RS-Java package and follow the same basic principles.
 */

typedef struct _RSFromPerlConverter RSFromPerlConverter;

typedef char * PerlClassInfoPtr;

typedef Rboolean (*FromPerlConverterMatch)(SV *obj, PerlClassInfoPtr, RSFromPerlConverter *converter);

typedef USER_OBJECT_ (*FromPerlConverter)(SV *obj, PerlClassInfoPtr, RSFromPerlConverter *converter);

typedef FromPerlConverterMatch FromTargetConverterMatch;
typedef FromPerlConverter      FromTargetConverter;

typedef enum { R_FUNCTIONS, PERL_ROUTINES} ConverterInfo;

typedef struct {
    USER_OBJECT_ match;
    USER_OBJECT_ converter;
    char *className;

} SFromPerlConverterFunctionData;


/* User data structure for converters written in Perl that convert a Perl object to an R object.*/
struct _PerlConverterRoutineData {

    CV *match;
    CV *converter;
 };

typedef struct _PerlConverterRoutineData SFromPerlConverterRoutineData;
typedef struct _PerlConverterRoutineData SToPerlConverterFunctionData;



typedef struct _RSToPerlConverter RSToPerlConverter;

struct _RSFromPerlConverter {
  FromPerlConverterMatch match;
  FromPerlConverter      converter;
  Rboolean               autoArray;
  void                  *userData;
  char                  *description;
  RSFromPerlConverter   *next;
};
 
/*
In RS-Java, have a java_type here.
 */
typedef Rboolean (*ToPerlConverterMatch)(USER_OBJECT_ obj, PerlClassInfoPtr perlClass, char *signature, Rboolean isArray, int arrayLen, RSToPerlConverter *);

typedef SV* (*ToPerlConverter)(USER_OBJECT_ obj, PerlClassInfoPtr perlClass, char *signature, Rboolean isArray, int arrayLen, RSToPerlConverter *);

typedef ToPerlConverterMatch ToTargetConverterMatch;
typedef ToPerlConverter      ToTargetConverter;


struct _RSToPerlConverter {

  ToPerlConverterMatch match;
  ToPerlConverter      converter;
  Rboolean             autoArray;   
  void                *userData;

  char                *description;  

  RSToPerlConverter   *next;
};    


#define ToPerlConverters   ToTargetConverters
#define FromPerlConverters FromTargetConverters

extern RSFromPerlConverter *FromPerlConverters;
extern RSToPerlConverter   *ToPerlConverters;


USER_OBJECT_ userLevelFromPerlConversion(SV *, Rboolean *ok);
SV *userLevelToPerlConversion(USER_OBJECT_ val, Rboolean *ok);


#define addFromPerlConverter addFromTargetConverter
#define addFromPerlConverterInfo addFromTargetConverterInfo

#define addToPerlConverter addToTargetConverter
#define addToPerlConverterInfo addToTargetConverterInfo

int addFromPerlConverter(RSFromPerlConverter *);
RSFromPerlConverter * addFromPerlConverterInfo(FromPerlConverterMatch match, FromPerlConverter converter, Rboolean autoArray, void *userData, char *description, int *index);

/* Done. */
int addToPerlConverter(RSToPerlConverter *);
RSToPerlConverter * addToPerlConverterInfo(ToPerlConverterMatch match, ToPerlConverter converter, Rboolean autoArray, void *userData, char *description, int *index);

RSFromPerlConverter *removeFromPerlConverterByIndex(int which);
RSFromPerlConverter *removeFromPerlConverterByDescription(char *desc, int *which);

USER_OBJECT_ RPerl(removeConverter)(USER_OBJECT_ id, USER_OBJECT_ fromPerl, USER_OBJECT_ description);


int getNumConverters(int which);
USER_OBJECT_ RPerl(getNumConverters)(USER_OBJECT_ which);
USER_OBJECT_ RPerl(getConverterDescriptions)(USER_OBJECT_ which);
char *fromPerlConverterDescription(RSFromPerlConverter *cvt);

/*
 The basic matching functions.
 ExactClassMatch, Derived From.
 */
void RPerl(registerDefaultConverters)();

#endif
