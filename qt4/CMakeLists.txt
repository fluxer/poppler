# Qt4 headers are not override clean so disable suggest-override if it's there
string(REPLACE "-Wsuggest-override" " " CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})

set(CMAKE_AUTOMOC TRUE)
set(CMAKE_AUTOUIC TRUE)

add_subdirectory(src)
add_subdirectory(tests)
add_subdirectory(demos)
