cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo)

add_library(libffi
        libffi/fixed/ffi.c
        libffi/fixed/ffiasm.S
        libffi/fixed/ffiload.c
        libffi/src/closures.c
        libffi/src/debug.c
        libffi/src/java_raw_api.c
        libffi/src/prep_cif.c
        libffi/src/raw_api.c
        libffi/src/tramp.c
        libffi/src/types.c
)
target_include_directories(libffi PRIVATE
        libffi/fixed
        libffi/include
)
