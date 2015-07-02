#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

EXTERN_C void xs_init (pTHX);

EXTERN_C void boot_R (pTHX_ CV* cv);
EXTERN_C void boot_DynaLoader (pTHX_ CV* cv);

EXTERN_C void
xs_init(pTHX)
{
    static const char file[] = __FILE__;
    dXSUB_SYS;
    PERL_UNUSED_CONTEXT;

    newXS("R::bootstrap", boot_R, file);
    /* DynaLoader is a special case */
    newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
}
