cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo)

add_library(nodeffi SHARED
        src/src/node_ffi.cc
        src/src/permission/ffi_permission.cc
)
target_include_directories(nodeffi PRIVATE
        src/deps/libffi/fixed
        src/deps/libffi/include
        ../node/src
        ../node/deps/v8/include
)
target_compile_definitions(nodeffi PRIVATE
        NODE_WANT_INTERNALS=1
        NODE_ENABLE_FFI=1
)
