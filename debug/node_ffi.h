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

    protected:
        static constexpr auto ABI = FFI_DEFAULT_ABI;
        ffi_cif cif{};
        std::unique_ptr<ffi_type*[]> types;
    };

    class FFIFunction : public FFIDefinition
    {
    public:
        explicit FFIFunction(const char* defStr, void* address);
        void setParam(int i, const void* ptr);
        void doInvoke(ffi_raw* result);

    protected:
        void (*invoker)(){};
        std::unique_ptr<ffi_raw[]> datas;
        std::unique_ptr<void*[]> args;
    };

    class FFICallback : public FFIDefinition
    {
    public:
        explicit FFICallback(const char* defStr);
        ~FFICallback();

    protected:
        static constexpr auto FCS = sizeof(ffi_closure);
        static void RawCallback(ffi_cif*, void*, void**, void*);
        ffi_closure* pfc{};
        void* address{};
    };
}

#endif  // defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#endif  // SRC_NODE_FFI_H_
