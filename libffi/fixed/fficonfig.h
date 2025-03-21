/*
 * This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#ifndef LIBFFI_FIXED_CONFIG_H
#define LIBFFI_FIXED_CONFIG_H

#define FFI_NO_RAW_API 1
#define FFI_NO_STRUCTS 1
#define FFI_STATIC_BUILD 1
#define HAVE_MEMCPY 1
#define STDC_HEADERS 1

#ifndef _MSC_VER
# define HAVE_ALLOCA_H 1
# define HAVE_HIDDEN_VISIBILITY_ATTRIBUTE 1
#endif

#ifndef _WIN32
# define HAVE_MEMFD_CREATE 1
#endif

// #define HAVE_LONG_DOUBLE 1
//
// /* Define if building universal (internal helper macro) */
// #define AC_APPLE_UNIVERSAL_BUILD
//
// /* Define to the flags needed for the .section .eh_frame directive. */
// #define EH_FRAME_FLAGS "a"
//
//
// /* Define this if you want statically defined trampolines */
// #define FFI_EXEC_STATIC_TRAMP 1
//
// /* Cannot use PROT_EXEC on this target, so, we revert to alternative means */
// #define FFI_EXEC_TRAMPOLINE_TABLE
//
// /* Define this if you want to enable pax emulated trampolines (experimental) */
// #define FFI_MMAP_EXEC_EMUTRAMP_PAX
//
// /* Cannot use malloc on this target, so, we revert to alternative means */
// #define FFI_MMAP_EXEC_WRIT
//
//
// /* Define if your compiler supports pointer authentication. */
// #define HAVE_ARM64E_PTRAUTH
//
// /* Define if your assembler supports .cfi_* directives. */
// #define HAVE_AS_CFI_PSEUDO_OP 1
//
//
// /* Define if your assembler supports unwind section type. */
// #define HAVE_AS_X86_64_UNWIND_SECTION_TYPE
//
// /* Define if your assembler supports PC relative relocs. */
// #define HAVE_AS_X86_PCREL 1
//
//
//
//
// /* Define if you have the long double type and it is bigger than a double */
//
// /* Define if you support more than one size of the long double type */
// #define HAVE_LONG_DOUBLE_VARIANT
//
//
// /* Define to 1 if you have the `memfd_create' function. */
//
//
// /* Define to 1 if you have the <sys/memfd.h> header file. */
// #define HAVE_SYS_MEMFD_H
//
//
// /* Define to 1 if all of the C90 standard headers exist (not just the ones
//    required in a freestanding environment). This macro is provided for
//    backward compatibility; new code need not use it. */
//
//
//
// /* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
//    significant byte first (like Motorola and SPARC, unlike Intel). */
// #if defined AC_APPLE_UNIVERSAL_BUILD
// # if defined __BIG_ENDIAN__
// #  define WORDS_BIGENDIAN 1
// # endif
// #else
// # ifndef WORDS_BIGENDIAN
// /* #  undef WORDS_BIGENDIAN */
// # endif
// #endif


#ifdef HAVE_HIDDEN_VISIBILITY_ATTRIBUTE
# ifdef LIBFFI_ASM
#  ifdef __APPLE__
#   define FFI_HIDDEN(name) .private_extern name
#  else
#   define FFI_HIDDEN(name) .hidden name
#  endif
# else
#  define FFI_HIDDEN __attribute__ ((visibility ("hidden")))
# endif
#else
# ifdef LIBFFI_ASM
#  define FFI_HIDDEN(name)
# else
#  define FFI_HIDDEN
# endif
#endif

#endif
