cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo)

add_library(libffi STATIC
        libffi/fixed/ffiload.c
        libffi/src/closures.c
        libffi/src/prep_cif.c
        libffi/src/types.c
        libffi/src/tramp.c
)
target_include_directories(libffi PUBLIC libffi/include libffi/fixed)

enable_language(ASM_MASM)
target_sources(libffi PRIVATE
        libffi/src/x86/ffi.c
        libffi/fixed/win32_x86.asm
)

add_executable(test-windows test-windows.cc)
target_link_libraries(test-windows PRIVATE libffi)
