cmake_minimum_required(VERSION 3.14)
project(DynCallDemo CXX)

add_subdirectory(dyncall-nodejs)

add_executable(test-windows test-windows.cc)
target_include_directories(test-windows PRIVATE dyncall-nodejs/dynload dyncall-nodejs/dyncall dyncall-nodejs/dyncallback)
target_link_libraries(test-windows PRIVATE dynload_s dyncall_s dyncallback_s)
