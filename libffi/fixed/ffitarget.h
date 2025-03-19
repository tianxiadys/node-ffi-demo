/*
 * This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#ifndef LIBFFI_TARGET_FIXED_H
#define LIBFFI_TARGET_FIXED_H

#ifndef LIBFFI_H
#error "Please do not include ffitarget.h directly into your source.  Use ffi.h instead."
#endif

#ifdef __x86_64__
# define X86_64
# ifdef _WIN32
#  define X86_WIN64
# elifdef __APPLE__
#  define X86_DARWIN
# endif
# include "../src/x86/ffitarget.h"
#elifdef __i386__
# define X86
# ifdef _WIN32
#  define X86_WIN32
# elifdef __APPLE__
#  define X86_DARWIN
# endif
# include "../src/x86/ffitarget.h"
#elifdef __powerpc64__
# define POWERPC
# define POWERPC64
# ifdef __APPLE__
#  define POWERPC_DARWIN64
# endif
# include "../src/powerpc/ffitarget.h"
#elifdef __powerpc__
# define POWERPC
# include "../src/powerpc/ffitarget.h"
#elifdef __aarch64__
# include "../src/aarch64/ffitarget.h"
#elifdef __arm__
# include "../src/arm/ffitarget.h"
#endif

#endif
