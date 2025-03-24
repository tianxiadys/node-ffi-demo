cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo)
add_subdirectory(libffi)

add_library(nodeffi SHARED src/node_ffi.cc)
target_link_libraries(nodeffi PRIVATE libffi)
target_include_directories(nodeffi PRIVATE ../node/src ../node/deps/v8/include)
target_compile_definitions(nodeffi PRIVATE NODE_WANT_INTERNALS=1)
