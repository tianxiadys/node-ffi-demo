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
        static constexpr auto ABI = FFI_DEFAULT_ABI;

    public:
        explicit FFIDefinition(const char* defStr);
        ffi_cif cif{};
        std::unique_ptr<ffi_type*[]> types;
    };

    class FFIFunction : public FFIDefinition
    {
    public:
    };

    class FFICallback : public FFIDefinition
    {
        static constexpr auto FCS = sizeof(ffi_closure);

    public:
        explicit FFICallback(const char* defStr);
        static void RawCallback(ffi_cif*, void*, void**, void*);
        ~FFICallback();
        ffi_closure* pfc{};
        void* address{};
    };
}

#endif  // defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#endif  // SRC_NODE_FFI_H_
