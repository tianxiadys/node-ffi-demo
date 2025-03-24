add_library(libffi SHARED
        fixed/ffi.c
        fixed/ffiload.c
        src/closures.c
        src/debug.c
        src/java_raw_api.c
        src/prep_cif.c
        src/raw_api.c
        src/tramp.c
        src/types.c
)
target_include_directories(libffi PUBLIC
        fixed
        include
)
if (MSVC)
  find_program(MASM_ARM armasm)
  find_program(MASM_ARM64 armasm64)
  add_custom_target(generate_msvc_asm
          WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
          DEPENDS fixed/ffiasm.S
          BYPRODUCTS ${CMAKE_BINARY_DIR}/ffiasm.asm
          COMMAND cl -nologo -EP -P -Ifixed -Iinclude "-Fi${CMAKE_BINARY_DIR}/ffiasm.asm" fixed/ffiasm.S
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
