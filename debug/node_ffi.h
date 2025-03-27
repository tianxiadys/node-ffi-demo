#ifndef SRC_NODE_FFI_H_
#define SRC_NODE_FFI_H_

#if defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS

#include "ffi.h"
#include <memory>

#define UNREACHABLE(x) static_assert(x)

namespace node::ffi
{
    class FFIDefinition
    {
    public:
        explicit FFIDefinition(const char* defStr);
        ffi_cif cif{};
        std::unique_ptr<ffi_type*[]> types;
    };

    class FFIFunction
    {
    };

    class FFICallback
    {
    };
}

#endif  // defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#endif  // SRC_NODE_FFI_H_
