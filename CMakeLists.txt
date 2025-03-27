cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo C CXX ASM ASM_MASM)
set(CMAKE_CXX_STANDARD 20)
###
add_library(nodeffi SHARED
        src/src/node_ffi.cc
        src/src/permission/ffi_permission.cc
)
target_compile_definitions(nodeffi PRIVATE
        NODE_WANT_INTERNALS=1
        NODE_ENABLE_FFI=1
)
target_include_directories(nodeffi PRIVATE
        src/deps/libffi/fixed
        src/deps/libffi/include
        ../node/src
        ../node/deps/v8/include
)
###
add_custom_target(generate_msvc_asm
        DEPENDS src/deps/libffi/fixed/ffiasm.S
        BYPRODUCTS ${CMAKE_BINARY_DIR}/ffiasm.asm
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/deps/libffi
        COMMAND cl -nologo -EP -P -Ifixed -Iinclude "-Fi${CMAKE_BINARY_DIR}/ffiasm.asm" fixed/ffiasm.S
)
###
add_library(libffi STATIC
        src/deps/libffi/fixed/ffi.c
        src/deps/libffi/src/closures.c
        src/deps/libffi/src/debug.c
        src/deps/libffi/src/java_raw_api.c
        src/deps/libffi/src/prep_cif.c
        src/deps/libffi/src/raw_api.c
        src/deps/libffi/src/tramp.c
        src/deps/libffi/src/types.c
        ${CMAKE_BINARY_DIR}/ffiasm.asm
)
target_include_directories(libffi PUBLIC
        src/deps/libffi/fixed
        src/deps/libffi/include
)
###
add_executable(debug1
        debug/node_debug1.cc
        debug/node_ffi.cc
)
target_compile_definitions(debug1 PRIVATE
        NODE_WANT_INTERNALS=1
        NODE_ENABLE_FFI=1
)
target_include_directories(debug1 PRIVATE
        ../node/src
        ../node/deps/v8/include
)
target_link_libraries(debug1 PRIVATE
        libffi
)
