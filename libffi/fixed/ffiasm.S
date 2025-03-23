/*
 * This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#if defined _M_X64 || defined __x86_64__
# if defined _MSC_VER
#  include "../src/x86/win64_intel.S"
# elif defined _WIN32
#  include "../src/x86/win64.S"
# else
#  include "../src/x86/unix64.S"
# endif
#elif defined _M_IX86 || defined __i386__
# if defined _MSC_VER
#  include "../src/x86/sysv_intel.S"
# else
#  include "../src/x86/sysv.S"
# endif
#elif defined _M_ARM64 || defined __aarch64__
# if defined _MSC_VER
#  include "../src/aarch64/win64_armasm.S"
# else
#  include "../src/aarch64/sysv.S"
# endif
#elif defined _M_ARM || defined __arm__
# if defined _MSC_VER
#  include "../src/arm/sysv_msvc_arm32.S"
# else
#  include "../src/arm/sysv.S"
# endif
#elif defined __powerpc__
# if defined _AIX
#  include "../src/powerpc/aix.S"
#  include "../src/powerpc/aix_closure.S"
# elif defined __powerpc64__
#  include "../src/powerpc/linux64.S"
#  include "../src/powerpc/linux64_closure.S"
# else
#  include "../src/powerpc/sysv.S"
#  include "../src/powerpc/ppc_closure.S"
# endif
#else
# error "Unsupported platform"
#endif
