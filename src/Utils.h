#ifndef RUTILS_H
#define RUTILS_H

#ifdef __cplusplus
extern "C" {
#endif


#include "RSCommon.h"

char ** characterVectorToArray(USER_OBJECT_ obj, Rboolean copyElements);
char **characterVectorToNullTerminatedArray(USER_OBJECT_ obj, Rboolean copyElements);

void my_exit_jump(void *ptr);

#ifdef __cplusplus
}
#endif

#endif
