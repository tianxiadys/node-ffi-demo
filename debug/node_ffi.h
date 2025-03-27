#ifndef SRC_NODE_FFI_H_
#define SRC_NODE_FFI_H_

#if defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS

#include "ffi.h"
#include <memory>

namespace node::ffi
{
    class FFIFunction
    {
        ffi_cif ffiCif{};
        std::unique_ptr<ffi_type*[]> typeArr;

    public:
        static ffi_type* parseType(char code);
        explicit FFIFunction(const char* defStr);
    };
}

#endif  // defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#endif  // SRC_NODE_FFI_H_
