#ifndef RSPERL_H
#define RSPERL_H
#include <EXTERN.h>               /* from the Perl distribution     */
#include <perl.h>                 /* from the Perl distribution     */

#include <perlapi.h>

#include "RSCommon.h"




#define R_PERL_DEBUG 0
#undef R_PERL_DEBUG

extern PerlInterpreter *RS_perl;  /***    The Perl interpreter    ***/

PerlInterpreter *RS_resolvePerlInterpreter(USER_OBJECT_ which);
USER_OBJECT_ RS_getPerlInterpreter(USER_OBJECT_ all);

#if 1
typedef XSINIT_t PerlExtensionInit;
#else
typedef void (*PerlExtensionInit)(void);
#endif
PerlExtensionInit getPerlExtensionRoutine(USER_OBJECT_ rsExtensions);

/* patch up to > perl 5.15 */
#define sv_undef PL_sv_undef

#endif

