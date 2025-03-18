cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo)

add_library(libffi STATIC
        libffi/src/closures.c
        libffi/src/dlmalloc.c
        libffi/src/prep_cif.c
        libffi/src/raw_api.c
        libffi/src/types.c
)
target_include_directories(libffi PUBLIC libffi/include libffi/gen)

add_executable(test-windows test-windows.cc)
target_link_libraries(test-windows PRIVATE libffi)
