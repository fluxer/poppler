# Copyright 2008 Pino Toscano, <pino@kde.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

macro(POPPLER_ADD_TEST exe build_flag)
  set(build_test ${${build_flag}})
  if(NOT build_test)
    set(_add_executable_param ${_add_executable_param} EXCLUDE_FROM_ALL)
  endif(NOT build_test)

  add_executable(${exe} ${_add_executable_param} ${ARGN})

  # if the tests are EXCLUDE_FROM_ALL, add a target "buildtests" to build all tests
  if(NOT build_test)
    get_property(_buildtestsAdded GLOBAL PROPERTY BUILDTESTS_ADDED)
    if(NOT _buildtestsAdded)
      add_custom_target(buildtests)
      set_property(GLOBAL PROPERTY BUILDTESTS_ADDED TRUE)
    endif(NOT _buildtestsAdded)
    add_dependencies(buildtests ${exe})
  endif(NOT build_test)
endmacro(POPPLER_ADD_TEST)

macro(POPPLER_ADD_UNITTEST exe build_flag)
  set(build_test ${${build_flag}})
  if(NOT build_test)
    set(_add_executable_param ${_add_executable_param} EXCLUDE_FROM_ALL)
  endif(NOT build_test)

  add_executable(${exe} ${_add_executable_param} ${ARGN})
  add_test(${exe} ${EXECUTABLE_OUTPUT_PATH}/${exe})

  # if the tests are EXCLUDE_FROM_ALL, add a target "buildtests" to build all tests
  if(NOT build_test)
    get_property(_buildtestsAdded GLOBAL PROPERTY BUILDTESTS_ADDED)
    if(NOT _buildtestsAdded)
      add_custom_target(buildtests)
      set_property(GLOBAL PROPERTY BUILDTESTS_ADDED TRUE)
    endif(NOT _buildtestsAdded)
    add_dependencies(buildtests ${exe})
  endif(NOT build_test)
endmacro(POPPLER_ADD_UNITTEST)

macro(SHOW_END_MESSAGE what value)
  string(LENGTH ${what} length_what)
  math(EXPR left_char "20 - ${length_what}")
  set(blanks)
  foreach(_i RANGE 1 ${left_char})
    set(blanks "${blanks} ")
  endforeach(_i)

  message("  ${what}:${blanks} ${value}")
endmacro(SHOW_END_MESSAGE)

macro(SHOW_END_MESSAGE_YESNO what enabled)
  if(${enabled})
    set(enabled_string "yes")
  else(${enabled})
    set(enabled_string "no")
  endif(${enabled})

  show_end_message("${what}" "${enabled_string}")
endmacro(SHOW_END_MESSAGE_YESNO)

macro(POPPLER_CHECK_LINK_FLAG flag var)
   set(_save_CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES}")
   include(CheckCXXSourceCompiles)
   set(CMAKE_REQUIRED_LIBRARIES "${flag}")
   check_cxx_source_compiles("int main() { return 0; }" ${var})
   set(CMAKE_REQUIRED_LIBRARIES "${_save_CMAKE_REQUIRED_LIBRARIES}")
endmacro(POPPLER_CHECK_LINK_FLAG)


set(CMAKE_SYSTEM_INCLUDE_PATH ${CMAKE_SYSTEM_INCLUDE_PATH}
                              "${CMAKE_INSTALL_PREFIX}/include" )

set(CMAKE_SYSTEM_PROGRAM_PATH ${CMAKE_SYSTEM_PROGRAM_PATH}
                              "${CMAKE_INSTALL_PREFIX}/bin" )

set(CMAKE_SYSTEM_LIBRARY_PATH ${CMAKE_SYSTEM_LIBRARY_PATH}
                              "${CMAKE_INSTALL_PREFIX}/lib" )

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif(NOT CMAKE_BUILD_TYPE)
