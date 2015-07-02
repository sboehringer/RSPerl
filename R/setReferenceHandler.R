setPerlHandler <-
function(handler = referenceHandlerGenerator())
{
   .Call(RPerl_setDefaultHandler, handler)
}

getPerlHandler <-
function()
{
   .Call(RPerl_getDefaultHandler)
}
