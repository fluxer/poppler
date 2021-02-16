prefix=@CMAKE_INSTALL_PREFIX@
libdir=@CMAKE_INSTALL_FULL_LIBDIR@
includedir=@CMAKE_INSTALL_FULL_INCLUDEDIR@

Name: poppler-katie
Description: Katie bindings for poppler
Version: @POPPLER_VERSION@
Requires: KtCore KtGui KtXml

Libs: -L${libdir} -lpoppler-katie
Cflags: -I${includedir}/poppler/katie
