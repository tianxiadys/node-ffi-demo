/*
 * This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#include <fficonfig.h>

#if defined X86_WIN64
# include "../src/x86/ffiw64.c"
#elif defined X86_64
# include "../src/x86/ffi64.c"
#elif defined X86
# include "../src/x86/ffi.c"
#elif defined AARCH64
# include "../src/aarch64/ffi.c"
#elif defined ARM
# include "../src/arm/ffi.c"
#elif defined POWERPC64
# include "../src/powerpc/ffi.c"
# include "../src/powerpc/ffi_linux64.c"
#elif defined POWERPC
# include "../src/powerpc/ffi.c"
# include "../src/powerpc/ffi_sysc.c"
#else
# error "Unsupported platform"
#endif
