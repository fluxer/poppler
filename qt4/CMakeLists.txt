# Qt4 headers are not override clean so disable suggest-override if it's there
string(REPLACE "-Wsuggest-override" " " CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})

add_subdirectory(src)
# TODO:
if (NOT Katie_FOUND)
  add_subdirectory(tests)
endif()
add_subdirectory(demos)
