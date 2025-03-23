/*
 * This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#ifndef LIBFFI_FIXED_TARGET_H
#define LIBFFI_FIXED_TARGET_H

#ifndef LIBFFI_H
# error "Please do not include ffitarget.h directly into your source.  Use ffi.h instead."
#endif

#include <fficonfig.h>

#if defined X86 || defined X86_64
# include "../src/x86/ffitarget.h"
#elif defined AARCH64
# include "../src/aarch64/ffitarget.h"
#elif defined ARM
# include "../src/arm/ffitarget.h"
#elif defined POWERPC
# include "../src/powerpc/ffitarget.h"
#else
# error "Unsupported platform"
#endif

#endif
