#ifndef SRC_NODE_FFI_H_
#define SRC_NODE_FFI_H_

#if defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#include "ffi.h"

namespace node::ffi
{
    using binding::DLib;
    using v8::Context;
    using v8::External;
    using v8::FunctionCallbackInfo;
    using v8::Isolate;
    using v8::Local;
    using v8::Object;
    using v8::Value;

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
        Local<External> getAddress(Isolate* isolate) const;
        ~FFICallback();

    protected:
        static constexpr auto FCS = sizeof(ffi_closure);
        static void RawCallback(ffi_cif*, void*, void**, void*);
        ffi_closure* pfc{};
        void* address{};
    };
}

#endif // defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#endif // SRC_NODE_FFI_H_
