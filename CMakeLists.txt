cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo)
enable_language(ASM)

add_library(libffi STATIC
        libffi/fixed/ffiload.c
        libffi/src/closures.c
        libffi/src/dlmalloc.c
        libffi/src/prep_cif.c
        libffi/src/raw_api.c
        libffi/src/types.c
        libffi/src/tramp.c
)
target_include_directories(libffi PUBLIC libffi/include libffi/fixed)
target_sources(libffi PRIVATE
        libffi/src/x86/ffiw64.c
        libffi/src/x86/win64.S
)

add_executable(test-windows test-windows.cc)
target_link_libraries(test-windows PRIVATE libffi)
