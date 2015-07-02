getPerlScript <-
function(name)
{  
          # For S-Plus, this needs to be determined at installation time
          #  in the configure.in file
          #     paste(\"${INSTALL_DIR}/inst/scripts/\", name,sep=\"\")
          #  See previous versions of configure.in.

  system.file("scripts", name, package="RSPerl")
}
