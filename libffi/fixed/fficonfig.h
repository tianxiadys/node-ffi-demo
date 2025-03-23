/*
* This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#ifndef LIBFFI_FIXED_CONFIG_H
#define LIBFFI_FIXED_CONFIG_H

#define EH_FRAME_FLAGS "a"
#define FFI_NO_RAW_API 1
#define FFI_STATIC_BUILD 1
#define HAVE_AS_X86_PCREL 1
#define STDC_HEADERS 1

#if defined _M_X64_ || defined __x86_64__
# define X86_64 1
# if defined _WIN32
#  define X86_WIN64 1
# elif defined __APPLE__
#  define X86_DARWIN 1
# endif
#elif defined _M_IX86 || defined __i386__
# define X86 1
# if defined _WIN32
#  define X86_WIN32 1
# elif defined __APPLE__
#  define X86_DARWIN 1
# endif
#elif defined _M_ARM64 || defined __aarch64__
# define AARCH64 1
#elif defined _M_ARM || defined __arm__
# define ARM 1
#elif defined __powerpc64__
# define POWERPC 1
# define POWERPC64 1
#elif defined __powerpc__
# define POWERPC 1
#else
# error "Unsupported platform"
#endif

#if defined __linux__
# define HAVE_AS_X86_64_UNWIND_SECTION_TYPE 1
# define HAVE_MEMFD_CREATE 1
# if defined X86 || defined X86_64 || defined ARM || defined AARCH64
#  define FFI_EXEC_STATIC_TRAMP 1
# endif
#endif

#if defined __linux__ || defined __APPLE__
# define HAVE_ALLOCA_H 1
#endif

#if defined __GNUC__
# define HAVE_AS_CFI_PSEUDO_OP 1
# if defined LIBFFI_ASM
#  if defined __APPLE__
#   define FFI_HIDDEN(name) .private_extern name
#  else
#   define FFI_HIDDEN(name) .hidden name
#  endif
# else
#  define FFI_HIDDEN __attribute__((visibility("hidden")))
# endif
#else
# if defined LIBFFI_ASM
#  define FFI_HIDDEN(name)
# else
#  define FFI_HIDDEN
# endif
#endif

#endif
