# Try to find NSS3, once done this will define:
#
#  NSS3_FOUND - system has NSS3
#  NSS3_INCLUDES - the NSS3 include directory
#  NSS3_LIBRARIES - the libraries needed to use NSS3
#
# Copyright (c) 2015 Ivailo Monev <xakepa10@gmail.com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

if(NOT WIN32)
    include(FindPkgConfig)
    pkg_check_modules(PC_NSS3 QUIET nss)

    set(NSS3_INCLUDES ${PC_NSS3_INCLUDE_DIRS})
    set(NSS3_LIBRARIES ${PC_NSS3_LIBRARIES})
endif()

set(NSS3_VERSION ${PC_NSS3_VERSION})

if(NOT NSS3_INCLUDES OR NOT NSS3_LIBRARIES)
    find_path(NSS3_INCLUDES
        NAMES nss/nss.h
        HINTS $ENV{NSS3DIR}/include
    )

    find_library(NSS3_LIBRARIES
        NAMES nss3
        HINTS $ENV{NSS3DIR}/lib
    )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NSS3
    VERSION_VAR NSS3_VERSION
    REQUIRED_VARS NSS3_LIBRARIES NSS3_INCLUDES
)

mark_as_advanced(NSS3_INCLUDES NSS3_LIBRARIES)
