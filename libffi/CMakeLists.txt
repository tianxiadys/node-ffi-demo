cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo2)

add_library(libffi fixed/ffi.c fixed/ffiload.c)
target_include_directories(libffi PRIVATE fixed include)
