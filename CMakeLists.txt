cmake_minimum_required(VERSION 3.14)
project(NodeFfiDemo)

add_library(libffi SHARED
        libffi/fixed/ffi.c
        libffi/fixed/ffiload.c
        libffi/src/closures.c
        libffi/src/debug.c
        libffi/src/java_raw_api.c
        libffi/src/prep_cif.c
        libffi/src/raw_api.c
        libffi/src/tramp.c
        libffi/src/types.c
)
target_include_directories(libffi PUBLIC
        libffi/fixed
        libffi/include
)
if (MSVC)
  find_program(MASM_ARM armasm)
  find_program(MASM_ARM64 armasm64)
  add_custom_target(generate_msvc_asm
          WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
          DEPENDS libffi/fixed/ffiasm.S
          BYPRODUCTS ${CMAKE_BINARY_DIR}/ffiasm.asm
          COMMAND cl -nologo -EP -P -Ilibffi/fixed -Ilibffi/include "-Fi${CMAKE_BINARY_DIR}/ffiasm.asm" libffi/fixed/ffiasm.S
  )
  if (MASM_ARM)
    add_custom_target(compile_msvc_asm
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ffiasm.asm
            BYPRODUCTS ffiasm.obj
            COMMAND armasm ffiasm.asm ffiasm.obj
    )
    target_link_options(libffi PRIVATE ffiasm.obj)
  elseif (MASM_ARM64)
    add_custom_target(compile_msvc_asm
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ffiasm.asm
            BYPRODUCTS ffiasm.obj
            COMMAND armasm64 ffiasm.asm ffiasm.obj
    )
    target_link_options(libffi PRIVATE ffiasm.obj)
  else ()
    enable_language(ASM_MASM)
    target_sources(libffi PRIVATE ${CMAKE_BINARY_DIR}/ffiasm.asm)
  endif ()
else ()
  enable_language(ASM)
  target_sources(libffi PRIVATE fixed/ffiasm.S)
endif ()

add_library(nodeffi SHARED src/node_ffi.cc)
target_link_libraries(nodeffi PRIVATE libffi)
target_include_directories(nodeffi PRIVATE ../node/src ../node/deps/v8/include)
target_compile_definitions(nodeffi PRIVATE NODE_WANT_INTERNALS=1)
