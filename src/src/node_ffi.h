#ifndef SRC_NODE_FFI_H_
#define SRC_NODE_FFI_H_

#if defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#include "ffi.h"

namespace node::ffi
{
using binding::DLib;
using v8::ArrayBuffer;
using v8::BigInt;
using v8::Context;
using v8::External;
using v8::FunctionCallbackInfo;
using v8::Int32;
using v8::Isolate;
using v8::Local;
using v8::Number;
using v8::Object;
using v8::Uint32;
using v8::Value;

class FFILibrary : public DLib
{
public:
    explicit FFILibrary(const char* libPath);
    ~FFILibrary();
};

class FFIDefinition
{
public:
    explicit FFIDefinition(const char* defStr);
    void readValue(int i, ffi_raw* raw, Local<Value> value) const;
    Local<Value> wrapValue(int i, ffi_raw* raw, Isolate* isolate) const;

protected:
    static constexpr auto ABI = FFI_DEFAULT_ABI;
    ffi_cif cif{};
    std::unique_ptr<ffi_type*[]> types;
};

class FFIFunction : public FFIDefinition
{
public:
    explicit FFIFunction(const char* defStr, void* address);
    void setParam(int i, Local<Value> value);
    Local<Value> doInvoke(Isolate* isolate);

protected:
    void (*invoker)(){};
    std::unique_ptr<ffi_raw[]> datas;
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

#endif // defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#endif // SRC_NODE_FFI_H_
