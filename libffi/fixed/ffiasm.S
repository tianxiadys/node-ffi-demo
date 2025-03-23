/*
 * This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#include <fficonfig.h>

#if defined X86_64
# if defined _MSC_VER
#  include "../src/x86/win64_intel.S"
# elif defined _WIN32
#  include "../src/x86/win64.S"
# else
#  include "../src/x86/unix64.S"
# endif
#elif defined X86
# if defined _MSC_VER
#  include "../src/x86/sysv_intel.S"
# else
#  include "../src/x86/sysv.S"
# endif
#elif defined AARCH64
# if defined _MSC_VER
#  include "../src/aarch64/win64_armasm.S"
# else
#  include "../src/aarch64/sysv.S"
# endif
#elif defined ARM
# if defined _MSC_VER
#  include "../src/arm/sysv_msvc_arm32.S"
# else
#  include "../src/arm/sysv.S"
# endif
#elif defined POWERPC
# if defined _AIX
#  include "../src/powerpc/aix.S"
#  include "../src/powerpc/aix_closure.S"
# elif defined POWERPC64
#  include "../src/powerpc/linux64.S"
#  include "../src/powerpc/linux64_closure.S"
# else
#  include "../src/powerpc/sysv.S"
#  include "../src/powerpc/ppc_closure.S"
# endif
#else
# error "Unsupported platform"
#endif
