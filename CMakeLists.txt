project(poppler)

cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)

include(PopplerMacros)
include(MacroOptionalFindPackage)
include(MacroEnsureVersion)
include(MacroBoolTo01)
include(GNUInstallDirs)

find_package(PkgConfig)

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads)

include(TestBigEndian)
test_big_endian(WORDS_BIGENDIAN)
include(CheckFileOffsetBits)
CHECK_FILE_OFFSET_BITS()

set(POPPLER_MAJOR_VERSION "0")
set(POPPLER_MINOR_VERSION "61")
set(POPPLER_MICRO_VERSION "1")
set(POPPLER_VERSION "${POPPLER_MAJOR_VERSION}.${POPPLER_MINOR_VERSION}.${POPPLER_MICRO_VERSION}")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
# put the include directories of the sources before other include paths
# (eg, system includes)
set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

# command line switches
option(ENABLE_XPDF_HEADERS "Install unsupported xpdf headers." OFF)
option(BUILD_TESTS "Whether compile the test programs." ON)
option(BUILD_QT4_TESTS "Whether compile the Qt4 test programs." ON)
option(ENABLE_SPLASH "Build the Splash graphics backend." ON)
option(ENABLE_UTILS "Compile poppler command line utils." ON)
set(ENABLE_LIBOPENJPEG "auto" CACHE STRING "Use libopenjpeg for JPX streams. Possible values: auto, openjpeg1, openjpeg2, unmaintained, none. 'auto' prefers openjpeg2 over openjpeg1 if both are available. 'unmaintained' gives you the internal unmaintained decoder. Use at your own risk. 'none' compiles no JPX decoder at all. Default: auto")
set(ENABLE_CMS "auto" CACHE STRING "Use color management system. Possible values: auto, lcms1, lcms2. 'auto' prefers lcms2 over lcms1 if both are available. Unset to disable color management system.")
set(ENABLE_DCTDECODER "libjpeg" CACHE STRING "Use libjpeg for DCT streams. Possible values: libjpeg, unmaintained, none. will use libjpeg if available or fail if not. 'unmaintained' gives you the internal unmaintained decoder. Use at your own risk. 'none' compiles no DCT decoder at all. Default: libjpeg")
option(ENABLE_LIBCURL "Build libcurl based HTTP support." ON)
option(ENABLE_ZLIB "Build with zlib." ON)
option(ENABLE_ZLIB_UNCOMPRESS "Use zlib to uncompress flate streams (not totally safe)." OFF)
option(SPLASH_CMYK "Include support for CMYK rasterization." OFF)
option(USE_FIXEDPOINT "Use fixed point arithmetic in the Splash backend" OFF)
option(USE_FLOAT "Use single precision arithmetic in the Splash backend" OFF)
option(BUILD_SHARED_LIBS "Build poppler as a shared library" ON)

set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

set(TESTDATADIR "${CMAKE_SOURCE_DIR}/../test" CACHE STRING "Specify test data dir.")
if(NOT (EXISTS ${TESTDATADIR} AND EXISTS ${TESTDATADIR}/test-poppler.c))
  message(WARNING "
 No test data found in $testdatadir.
 You will not be able to run 'make test' successfully.

 The test data is not included in the source packages
 and is also not part of the main git repository. Instead,
 you can checkout the test data from its own git
 repository with:

   git clone git://git.freedesktop.org/git/poppler/test

 You should checkout the test data as a sibling of your
 poppler source folder or specify the location of your
 checkout with -DTESTDATADIR=/path/to/checkoutdir/test.
  ")
endif()

if(CMAKE_USE_PTHREADS_INIT)
  set(MULTITHREADED ON)
endif()

# Enable these unconditionally.
set(OPI_SUPPORT ON)
set(TEXTOUT_WORD_LIST ON)

# setting the minimum required versions for some components
set(QT4_MIN_VERSION "4.7.0")

macro_bool_to_01(ENABLE_SPLASH HAVE_SPLASH)
find_package(Freetype REQUIRED)
find_package(Fontconfig REQUIRED)
macro_optional_find_package(JPEG)
macro_optional_find_package(PNG)
macro_optional_find_package(TIFF)
macro_optional_find_package(NSS3)
if(ENABLE_DCTDECODER STREQUAL "libjpeg")
  if(JPEG_FOUND)
    set(ENABLE_LIBJPEG ${JPEG_FOUND})
  else()
    message(FATAL_ERROR "Install libjpeg before trying to build poppler. You can also decide to use the internal unmaintained DCT decoder or none at all.")
  endif()
  set(HAVE_DCT_DECODER ON)
elseif(ENABLE_DCTDECODER STREQUAL "unmaintained")
  set(ENABLE_LIBJPEG OFF)
  set(HAVE_DCT_DECODER ON)
elseif(ENABLE_DCTDECODER STREQUAL "none")
  set(ENABLE_LIBJPEG OFF)
  set(HAVE_DCT_DECODER OFF)
else()
  message(FATAL_ERROR "Invalid ENABLE_DCTDECODER value.")
endif()

find_package(Katie REQUIRED)

add_definitions(${QT4_DEFINITIONS})

include_directories(
  ${CMAKE_SOURCE_DIR}/qt4/src
  ${QT4_INCLUDE_DIR}
  ${CMAKE_BINARY_DIR}/qt4/src
)

set(CMAKE_AUTOMOC TRUE)
set(CMAKE_AUTOUIC TRUE)

if(ENABLE_ZLIB)
  find_package(ZLIB)
  set(ENABLE_ZLIB ${ZLIB_FOUND})
endif()
if(ENABLE_ZLIB_UNCOMPRESS AND NOT ENABLE_ZLIB)
  message("Warning: ENABLE_ZLIB_UNCOMPRESS requires ENABLE_ZLIB")
  set(ENABLE_ZLIB_UNCOMPRESS FALSE)
endif()
set(USE_OPENJPEG1 FALSE)
set(USE_OPENJPEG2 FALSE)
set(WITH_OPENJPEG FALSE)
if(ENABLE_LIBOPENJPEG STREQUAL "auto")
  find_package(LIBOPENJPEG2)
  set(USE_OPENJPEG2 ${LIBOPENJPEG2_FOUND})
  set(WITH_OPENJPEG ${LIBOPENJPEG2_FOUND})
  if(NOT LIBOPENJPEG2_FOUND)
    find_package(LIBOPENJPEG)
    set(USE_OPENJPEG1 ${LIBOPENJPEG_FOUND})
    set(WITH_OPENJPEG ${LIBOPENJPEG_FOUND})  
    if(NOT LIBOPENJPEG_FOUND)
      message(FATAL_ERROR "Install libopenjpeg2 or libopenjpeg1 before trying to build poppler. You can also decide to use the internal unmaintained JPX decoder or none at all.")
    endif()
  endif()
  set(HAVE_JPX_DECODER ON)
elseif(ENABLE_LIBOPENJPEG STREQUAL "openjpeg1")
  find_package(LIBOPENJPEG)
  set(USE_OPENJPEG1 ${LIBOPENJPEG_FOUND})
  set(WITH_OPENJPEG ${LIBOPENJPEG_FOUND})
  if(NOT LIBOPENJPEG_FOUND)
    message(FATAL_ERROR "Install libopenjpeg1 before trying to build poppler. You can also decide to use the internal unmaintained JPX decoder or none at all.")
  endif()
  set(HAVE_JPX_DECODER ON)
elseif(ENABLE_LIBOPENJPEG STREQUAL "openjpeg2")
  find_package(LIBOPENJPEG2)
  set(USE_OPENJPEG2 ${LIBOPENJPEG2_FOUND})
  set(WITH_OPENJPEG ${LIBOPENJPEG2_FOUND})
  if(NOT LIBOPENJPEG2_FOUND)
    message(FATAL_ERROR "Install libopenjpeg2 before trying to build poppler. You can also decide to use the internal unmaintained JPX decoder or none at all.")
  endif()
  set(HAVE_JPX_DECODER ON)
elseif(ENABLE_LIBOPENJPEG STREQUAL "unmaintained")
  set(WITH_OPENJPEG OFF)
  set(HAVE_JPX_DECODER ON)
elseif(ENABLE_LIBOPENJPEG STREQUAL "none")
  set(WITH_OPENJPEG OFF)
  set(HAVE_JPX_DECODER OFF)
else()
  message(FATAL_ERROR "Invalid ENABLE_LIBOPENJPEG value: ${ENABLE_LIBOPENJPEG}")
endif()
set(ENABLE_LIBOPENJPEG "${WITH_OPENJPEG}")
if(ENABLE_CMS STREQUAL "auto")
  find_package(LCMS2)
  set(USE_CMS ${LCMS2_FOUND})
  if(NOT LCMS2_FOUND)
    find_package(LCMS)
    set(USE_CMS ${LCMS_FOUND})
    set(USE_LCMS1 ${LCMS_FOUND})
  endif()
elseif(ENABLE_CMS STREQUAL "lcms1")
  find_package(LCMS)
  set(USE_CMS ${LCMS_FOUND})
  set(USE_LCMS1 ${LCMS_FOUND})
elseif(ENABLE_CMS STREQUAL "lcms2")
  find_package(LCMS2)
  set(USE_CMS ${LCMS2_FOUND})
endif()
if(ENABLE_LIBCURL)
  find_package(CURL)
  if(CURL_FOUND)
    include_directories(${CURL_INCLUDE_DIR})
    set(POPPLER_HAS_CURL_SUPPORT ON)
  else()
    set(ENABLE_LIBCURL OFF)
  endif()
endif()

if(FONTCONFIG_FOUND)
  add_definitions(${FONTCONFIG_DEFINITIONS})
  include_directories(${FONTCONFIG_INCLUDE_DIR})
endif()

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/fofi
  ${CMAKE_CURRENT_SOURCE_DIR}/goo
  ${CMAKE_CURRENT_SOURCE_DIR}/poppler
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}/poppler
  ${FREETYPE_INCLUDE_DIRS}
)

if(ENABLE_ZLIB)
  include_directories(${ZLIB_INCLUDE_DIR})
endif()

if(NSS3_FOUND)
  include_directories(${NSS3_INCLUDES})
  set(ENABLE_NSS3 ON)
endif()
if(JPEG_FOUND)
  include_directories(${JPEG_INCLUDE_DIR})
endif()
if(PNG_FOUND)
  include_directories(${PNG_INCLUDE_DIR})
  set(ENABLE_LIBPNG ON)
endif()
if(TIFF_FOUND)
  include_directories(${TIFF_INCLUDE_DIR})
  set(ENABLE_LIBTIFF ON)
endif()
if(LIBOPENJPEG_FOUND)
  include_directories(${LIBOPENJPEG_INCLUDE_DIR})
endif()
if(LIBOPENJPEG2_FOUND)
  include_directories(${LIBOPENJPEG2_INCLUDE_DIRS})
endif()
if(LCMS_FOUND)
  include_directories(${LCMS_INCLUDE_DIR})
endif()
if(LCMS2_FOUND)
  include_directories(${LCMS2_INCLUDE_DIR})
endif()

# Recent versions of poppler-data install a .pc file.
# Use it to determine the encoding data path, if available.
# Default to the same prefix otherwise.
pkg_check_modules(POPPLER_DATA poppler-data)
if(POPPLER_DATA_FOUND)
  execute_process(COMMAND "${PKG_CONFIG_EXECUTABLE}" --variable=poppler_datadir poppler-data
                  RESULT_VARIABLE _result_var
                  OUTPUT_VARIABLE _output_var OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(_result_var STREQUAL "0" AND NOT _output_var STREQUAL "")
    set(POPPLER_DATADIR "${_output_var}")
  endif()
endif()
if(NOT DEFINED POPPLER_DATADIR)
  set(POPPLER_DATADIR "${CMAKE_INSTALL_PREFIX}/share/poppler")
endif()

include(ConfigureChecks.cmake)
configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)
configure_file(poppler/poppler-config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/poppler/poppler-config.h)


set(poppler_SRCS
  goo/gfile.cc
  goo/gmempp.cc
  goo/GooHash.cc
  goo/GooList.cc
  goo/GooTimer.cc
  goo/GooString.cc
  goo/gmem.cc
  goo/FixedPoint.cc
  goo/NetPBMWriter.cc
  goo/PNGWriter.cc
  goo/TiffWriter.cc
  goo/JpegWriter.cc
  goo/ImgWriter.cc
  goo/gstrtod.cc
  goo/grandom.cc
  goo/glibc.cc
  goo/glibc_strtok_r.cc
  fofi/FoFiBase.cc
  fofi/FoFiEncodings.cc
  fofi/FoFiTrueType.cc
  fofi/FoFiType1.cc
  fofi/FoFiType1C.cc
  fofi/FoFiIdentifier.cc
  poppler/Annot.cc
  poppler/Array.cc
  poppler/BuiltinFont.cc
  poppler/BuiltinFontTables.cc
  poppler/CachedFile.cc
  poppler/Catalog.cc
  poppler/CharCodeToUnicode.cc
  poppler/CMap.cc
  poppler/DateInfo.cc
  poppler/Decrypt.cc
  poppler/Dict.cc
  poppler/Error.cc
  poppler/FileSpec.cc
  poppler/FontEncodingTables.cc
  poppler/Form.cc
  poppler/FontInfo.cc
  poppler/Function.cc
  poppler/Gfx.cc
  poppler/GfxFont.cc
  poppler/GfxState.cc
  poppler/GlobalParams.cc
  poppler/Hints.cc
  poppler/JArithmeticDecoder.cc
  poppler/JBIG2Stream.cc
  poppler/Lexer.cc
  poppler/Link.cc
  poppler/Linearization.cc
  poppler/LocalPDFDocBuilder.cc
  poppler/MarkedContentOutputDev.cc
  poppler/NameToCharCode.cc
  poppler/Object.cc
  poppler/OptionalContent.cc
  poppler/Outline.cc
  poppler/OutputDev.cc
  poppler/Page.cc
  poppler/PageTransition.cc
  poppler/Parser.cc
  poppler/PDFDoc.cc
  poppler/PDFDocEncoding.cc
  poppler/PDFDocFactory.cc
  poppler/PopplerCache.cc
  poppler/ProfileData.cc
  poppler/PreScanOutputDev.cc
  poppler/PSTokenizer.cc
  poppler/SignatureInfo.cc
  poppler/Stream.cc
  poppler/StructTreeRoot.cc
  poppler/StructElement.cc
  poppler/UnicodeMap.cc
  poppler/UnicodeTypeTable.cc
  poppler/UTF.cc
  poppler/XRef.cc
  poppler/PSOutputDev.cc
  poppler/TextOutputDev.cc
  poppler/PageLabelInfo.cc
  poppler/SecurityHandler.cc
  poppler/StdinCachedFile.cc
  poppler/StdinPDFDocBuilder.cc
  poppler/Sound.cc
  poppler/ViewerPreferences.cc
  poppler/XpdfPluginAPI.cc
  poppler/Movie.cc
  poppler/Rendition.cc
  qt4/src/poppler-annotation.cc
  qt4/src/poppler-document.cc
  qt4/src/poppler-embeddedfile.cc
  qt4/src/poppler-fontinfo.cc
  qt4/src/poppler-form.cc
  qt4/src/poppler-link.cc
  qt4/src/poppler-link-extractor.cc
  qt4/src/poppler-movie.cc
  qt4/src/poppler-optcontent.cc
  qt4/src/poppler-page.cc
  qt4/src/poppler-base-converter.cc
  qt4/src/poppler-pdf-converter.cc
  qt4/src/poppler-private.cc
  qt4/src/poppler-ps-converter.cc
  qt4/src/poppler-qiodeviceoutstream.cc
  qt4/src/poppler-sound.cc
  qt4/src/poppler-textbox.cc
  qt4/src/poppler-page-transition.cc
  qt4/src/poppler-media.cc
  qt4/src/ArthurOutputDev.cc
)
set(poppler_LIBS ${FREETYPE_LIBRARIES})
set(poppler_public_LIBS ${QT4_QTCORE_LIBRARY} ${QT4_QTGUI_LIBRARY} ${QT4_QTXML_LIBRARY})
if(ENABLE_SPLASH)
  set(poppler_SRCS ${poppler_SRCS}
    poppler/SplashOutputDev.cc
    splash/Splash.cc
    splash/SplashBitmap.cc
    splash/SplashClip.cc
    splash/SplashFTFont.cc
    splash/SplashFTFontEngine.cc
    splash/SplashFTFontFile.cc
    splash/SplashFont.cc
    splash/SplashFontEngine.cc
    splash/SplashFontFile.cc
    splash/SplashFontFileID.cc
    splash/SplashPath.cc
    splash/SplashPattern.cc
    splash/SplashScreen.cc
    splash/SplashState.cc
    splash/SplashXPath.cc
    splash/SplashXPathScanner.cc
  )
endif()
if(FONTCONFIG_FOUND)
  set(poppler_LIBS ${poppler_LIBS} ${FONTCONFIG_LIBRARIES})
endif()

if(JPEG_FOUND)
  set(poppler_SRCS ${poppler_SRCS}
    poppler/DCTStream.cc
  )
  set(poppler_LIBS ${poppler_LIBS} ${JPEG_LIBRARIES})
endif()
if(ENABLE_ZLIB)
  set(poppler_SRCS ${poppler_SRCS}
    poppler/FlateEncoder.cc
  )
  set(poppler_LIBS ${poppler_LIBS} ${ZLIB_LIBRARIES})
endif()
if(ENABLE_ZLIB_UNCOMPRESS)
  set(poppler_SRCS ${poppler_SRCS}
    poppler/FlateStream.cc
  )
endif()
if(ENABLE_LIBCURL)
  set(poppler_SRCS ${poppler_SRCS}
    poppler/CurlCachedFile.cc
    poppler/CurlPDFDocBuilder.cc
  )
  set(poppler_LIBS ${poppler_LIBS} ${CURL_LIBRARIES})
endif()
if (ENABLE_NSS3)
  set(poppler_SRCS ${poppler_SRCS}
    poppler/SignatureHandler.cc
  )
  set(poppler_LIBS ${poppler_LIBS} ${NSS3_LIBRARIES})
endif()
if(LIBOPENJPEG_FOUND)
  set(poppler_SRCS ${poppler_SRCS}
    poppler/JPEG2000Stream.cc
  )
  set(poppler_LIBS ${poppler_LIBS} ${LIBOPENJPEG_LIBRARIES})
  add_definitions(-DUSE_OPENJPEG1)
elseif (LIBOPENJPEG2_FOUND)
  set(poppler_SRCS ${poppler_SRCS}
    poppler/JPEG2000Stream.cc
  )
  add_definitions(-DUSE_OPENJPEG2)
  set(poppler_LIBS ${poppler_LIBS} ${LIBOPENJPEG2_LIBRARIES})
else ()
  set(poppler_SRCS ${poppler_SRCS}
    poppler/JPXStream.cc
  )
endif()
if(USE_CMS)
  if(LCMS_FOUND)
    set(poppler_LIBS ${poppler_LIBS} ${LCMS_LIBRARIES})
  endif()
  if(LCMS2_FOUND)
    set(poppler_LIBS ${poppler_LIBS} ${LCMS2_LIBRARIES})
  endif()
endif()
if(PNG_FOUND)
  set(poppler_LIBS ${poppler_LIBS} ${PNG_LIBRARIES})
endif()
if(TIFF_FOUND)
  set(poppler_LIBS ${poppler_LIBS} ${TIFF_LIBRARIES})
endif()

add_library(poppler-katie ${poppler_SRCS})
set_target_properties(poppler-katie PROPERTIES VERSION ${POPPLER_MAJOR_VERSION}.${POPPLER_MINOR_VERSION} SOVERSION ${POPPLER_MAJOR_VERSION})
target_link_libraries(poppler-katie LINK_PRIVATE ${poppler_LIBS})
target_link_libraries(poppler-katie LINK_PUBLIC ${poppler_public_LIBS})
if(CMAKE_USE_PTHREADS_INIT)
   target_link_libraries(poppler-katie LINK_PRIVATE Threads::Threads)
endif()
install(TARGETS poppler-katie RUNTIME DESTINATION bin LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(ENABLE_XPDF_HEADERS)
  install(FILES
    poppler/Annot.h
    poppler/Array.h
    poppler/BuiltinFont.h
    poppler/BuiltinFontTables.h
    poppler/CachedFile.h
    poppler/Catalog.h
    poppler/CharCodeToUnicode.h
    poppler/CMap.h
    poppler/DateInfo.h
    poppler/Decrypt.h
    poppler/Dict.h
    poppler/Error.h
    poppler/FileSpec.h
    poppler/FontEncodingTables.h
    poppler/FontInfo.h
    poppler/Form.h
    poppler/Function.h
    poppler/Gfx.h
    poppler/GfxFont.h
    poppler/GfxState.h
    poppler/GfxState_helpers.h
    poppler/GlobalParams.h
    poppler/Hints.h
    poppler/JArithmeticDecoder.h
    poppler/JBIG2Stream.h
    poppler/Lexer.h
    poppler/Link.h
    poppler/Linearization.h
    poppler/LocalPDFDocBuilder.h
    poppler/MarkedContentOutputDev.h
    poppler/Movie.h
    poppler/NameToCharCode.h
    poppler/Object.h
    poppler/OptionalContent.h
    poppler/Outline.h
    poppler/OutputDev.h
    poppler/Page.h
    poppler/PageTransition.h
    poppler/Parser.h
    poppler/PDFDoc.h
    poppler/PDFDocBuilder.h
    poppler/PDFDocEncoding.h
    poppler/PDFDocFactory.h
    poppler/PopplerCache.h
    poppler/ProfileData.h
    poppler/PreScanOutputDev.h
    poppler/PSTokenizer.h
    poppler/Rendition.h
    poppler/Stream-CCITT.h
    poppler/Stream.h
    poppler/StructElement.h
    poppler/StructTreeRoot.h
    poppler/UnicodeMap.h
    poppler/UnicodeMapTables.h
    poppler/UnicodeTypeTable.h
    poppler/UnicodeCClassTables.h
    poppler/UnicodeCompTables.h
    poppler/UnicodeDecompTables.h
    poppler/ViewerPreferences.h
    poppler/XRef.h
    poppler/CharTypes.h
    poppler/CompactFontTables.h
    poppler/ErrorCodes.h
    poppler/NameToUnicodeTable.h
    poppler/PSOutputDev.h
    poppler/TextOutputDev.h
    poppler/SecurityHandler.h
    poppler/StdinCachedFile.h
    poppler/StdinPDFDocBuilder.h
    poppler/UTF.h
    poppler/UTF8.h
    poppler/XpdfPluginAPI.h
    poppler/Sound.h
    ${CMAKE_CURRENT_BINARY_DIR}/poppler/poppler-config.h
    DESTINATION include/poppler)
  install(FILES
    goo/GooHash.h
    goo/GooList.h
    goo/GooTimer.h
    goo/GooMutex.h
    goo/GooString.h
    goo/gtypes.h
    goo/gmem.h
    goo/gfile.h
    goo/FixedPoint.h
    goo/ImgWriter.h
    goo/GooLikely.h
    goo/gstrtod.h
    goo/grandom.h
    DESTINATION include/poppler/goo)
  if(PNG_FOUND)
    install(FILES
      goo/PNGWriter.h
      DESTINATION include/poppler/goo)
  endif()
  if(TIFF_FOUND)
    install(FILES
      goo/TiffWriter.h
      DESTINATION include/poppler/goo)
  endif()
  if(JPEG_FOUND)
    install(FILES
      goo/JpegWriter.h
      DESTINATION include/poppler/goo)
  endif()
  install(FILES
    fofi/FoFiBase.h
    fofi/FoFiEncodings.h
    fofi/FoFiTrueType.h
    fofi/FoFiType1.h
    fofi/FoFiType1C.h
    fofi/FoFiIdentifier.h
    DESTINATION include/poppler/fofi)
  if(ENABLE_LIBCURL)
    install(FILES
      poppler/CurlCachedFile.h
      poppler/CurlPDFDocBuilder.h
      DESTINATION include/poppler)
  endif()
  if(LIBOPENJPEG_FOUND)
    install(FILES
      poppler/JPEG2000Stream.h
      DESTINATION include/poppler)
  elseif(LIBOPENJPEG2_FOUND)
    install(FILES
      poppler/JPEG2000Stream.h
      DESTINATION include/poppler)
  else()
    install(FILES
      poppler/JPXStream.h
      DESTINATION include/poppler)
  endif()
  if(ENABLE_SPLASH)
    install(FILES
      poppler/SplashOutputDev.h
      DESTINATION include/poppler)
    install(FILES
      splash/Splash.h
      splash/SplashBitmap.h
      splash/SplashClip.h
      splash/SplashErrorCodes.h
      splash/SplashFTFont.h
      splash/SplashFTFontEngine.h
      splash/SplashFTFontFile.h
      splash/SplashFont.h
      splash/SplashFontEngine.h
      splash/SplashFontFile.h
      splash/SplashFontFileID.h
      splash/SplashGlyphBitmap.h
      splash/SplashMath.h
      splash/SplashPath.h
      splash/SplashPattern.h
      splash/SplashScreen.h
      splash/SplashState.h
      splash/SplashTypes.h
      splash/SplashXPath.h
      splash/SplashXPathScanner.h
      DESTINATION include/poppler/splash)
  endif()
endif()

install(FILES
  qt4/src/poppler-qt4.h
  qt4/src/poppler-link.h
  qt4/src/poppler-annotation.h
  qt4/src/poppler-form.h
  qt4/src/poppler-optcontent.h
  qt4/src/poppler-export.h
  qt4/src/poppler-page-transition.h
  qt4/src/poppler-media.h
  DESTINATION include/poppler/katie)

if(BUILD_TESTS OR BUILD_QT4_TESTS)
 # enable the testing facilities
  enable_testing()
endif()

if(ENABLE_UTILS)
  add_subdirectory(utils)
endif()
if(BUILD_TESTS)
    add_subdirectory(test)
endif()
add_subdirectory(qt4)

poppler_create_install_pkgconfig(poppler-katie.pc ${CMAKE_INSTALL_LIBDIR}/pkgconfig)


message("Building Poppler with support for:")
show_end_message_yesno("splash output" ENABLE_SPLASH)
if(SPLASH_CMYK)
  message("      with CMYK support")
endif()
show_end_message_yesno("use libjpeg" ENABLE_LIBJPEG)
show_end_message_yesno("use libpng" ENABLE_LIBPNG)
show_end_message_yesno("use libtiff" ENABLE_LIBTIFF)
show_end_message_yesno("use zlib compress" ENABLE_ZLIB)
show_end_message_yesno("use zlib uncompress" ENABLE_ZLIB_UNCOMPRESS)
show_end_message_yesno("use nss3" ENABLE_NSS3)
show_end_message_yesno("use curl" ENABLE_LIBCURL)
show_end_message_yesno("use libopenjpeg" WITH_OPENJPEG)
if(USE_OPENJPEG1)
  message("      with openjpeg1")
endif()
if(USE_OPENJPEG2)
  message("      with openjpeg2")
endif()
show_end_message_yesno("use cms" USE_CMS)
if(LCMS_FOUND)
  message("      with lcms1")
endif()
if(LCMS2_FOUND)
  message("      with lcms2")
endif()
show_end_message_yesno("command line utils" ENABLE_UTILS)
show_end_message("test data dir" ${TESTDATADIR})

if(NOT ENABLE_SPLASH)
  message("Warning: There is no rendering backend enabled")
endif()

if(USE_FIXEDPOINT AND USE_FLOAT)
  message("Warning: Single precision and fixed point options should not be enabled at the same time")
endif()

if(NOT ENABLE_LIBJPEG AND HAVE_DCT_DECODER)
  message("Warning: Using libjpeg is recommended. The internal DCT decoder is unmaintained.")
endif()

if(NOT HAVE_DCT_DECODER)
  message("Warning: You're not compiling any DCT decoder. Some files will fail to display properly.")
endif()

if(ENABLE_ZLIB_UNCOMPRESS)
  message("Warning: Using zlib is not totally safe")
endif()

if(NOT WITH_OPENJPEG AND HAVE_JPX_DECODER)
  message("Warning: Using libopenjpeg2 is recommended. The internal JPX decoder is unmaintained.")
endif()

if(NOT HAVE_JPX_DECODER)
  message("Warning: You're not compiling any JPX decoder. Some files will fail to display properly.")
endif()

set(ARCHIVE_NAME ${CMAKE_PROJECT_NAME}-${POPPLER_VERSION})
add_custom_target(dist
    COMMAND
        COMMAND git log --stat | fmt --split-only > ${CMAKE_BINARY_DIR}/ChangeLog
        COMMAND git archive --prefix=${ARCHIVE_NAME}/ HEAD > ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar
        COMMAND tar -C ${CMAKE_BINARY_DIR} -rf ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar ChangeLog --transform='s,,${ARCHIVE_NAME}/,'
        COMMAND tar -C ${CMAKE_BINARY_DIR} -rf ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar --transform='s,,${ARCHIVE_NAME}/,'
        COMMAND xz -9 ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
