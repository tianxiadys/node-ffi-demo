cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo C CXX ASM ASM_MASM)
set(CMAKE_CXX_STANDARD 20)
###
add_library(nodeffi SHARED
        src/src/node_ffi.cc
        src/src/node_options.cc
        src/src/permission/ffi_permission.cc
)
target_compile_definitions(nodeffi PRIVATE
        NODE_WANT_INTERNALS=1
        HAVE_FFI=1
)
target_include_directories(nodeffi PRIVATE
        src/deps/libffi/fixed
        src/deps/libffi/include
        ../node/src
        ../node/deps/v8/include
)
