cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo2)

add_library(libffi
        fixed/ffi.c
        fixed/ffiasm.S
        fixed/ffiload.c
        src/closures.c
        src/debug.c
        src/java_raw_api.c
        src/prep_cif.c
        src/raw_api.c
        src/tramp.c
        src/types.c
)
target_include_directories(libffi PRIVATE fixed include)
