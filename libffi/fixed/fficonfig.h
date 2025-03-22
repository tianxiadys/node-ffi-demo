/*
 * This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#ifndef LIBFFI_FIXED_CONFIG_H
#define LIBFFI_FIXED_CONFIG_H

#define FFI_NO_RAW_API 1
#define STDC_HEADERS 1

#ifndef _WIN32
# define HAVE_ALLOCA_H 1
# define HAVE_DLFCN_H 1
# define HAVE_UNISTD_H 1
#endif

#if defined __linux__
/* Define this if you want statically defined trampolines */
#define FFI_EXEC_STATIC_TRAMP 1
/* Define to 1 if you have the `memfd_create' function. */
#define HAVE_MEMFD_CREATE 1
#endif
/* Cannot use PROT_EXEC on this target, so, we revert to alternative means */
/* #undef FFI_EXEC_TRAMPOLINE_TABLE */
/* Define this if you want to enable pax emulated trampolines (experimental)
   */
/* #undef FFI_MMAP_EXEC_EMUTRAMP_PAX */
/* Cannot use malloc on this target, so, we revert to alternative means */
/* #undef FFI_MMAP_EXEC_WRIT */



/* Define to the flags needed for the .section .eh_frame directive. */
#define EH_FRAME_FLAGS "a"
/* Define if .eh_frame sections should be read-only. */
#define HAVE_RO_EH_FRAME 1
/* Define if your assembler supports .cfi_* directives. */
#define HAVE_AS_CFI_PSEUDO_OP 1


/* Define if your compiler supports pointer authentication. */
/* #undef HAVE_ARM64E_PTRAUTH */
/* Define if the compiler uses zarch features. */
/* #undef HAVE_AS_S390_ZARCH */
/* Define if your assembler supports unwind section type. */
#define HAVE_AS_X86_64_UNWIND_SECTION_TYPE 1
/* Define if your assembler supports PC relative relocs. */
#define HAVE_AS_X86_PCREL 1










#ifndef _MSC_VER
# ifdef LIBFFI_ASM
#  ifdef __APPLE__
#   define FFI_HIDDEN(name) .private_extern name
#  else
#   define FFI_HIDDEN(name) .hidden name
#  endif
# else
#  define FFI_HIDDEN __attribute__((visibility("hidden")))
# endif
#else
# ifdef LIBFFI_ASM
#  define FFI_HIDDEN(name)
# else
#  define FFI_HIDDEN
# endif
#endif

#endif
