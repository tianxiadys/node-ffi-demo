#ifndef SRC_NODE_FFI_H_
#define SRC_NODE_FFI_H_

#if defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#include "ffi.h"
#include "node_binding.h"
#include "v8.h"

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

void* readAddress(Local<Value> value);
int64_t readInt64(Local<Value> value);
uint64_t readUInt64(Local<Value> value);
double readDouble(Local<Value> value);
std::string readString(Local<Value> value, Isolate* isolate);

class FFILibrary : public DLib
{
public:
    explicit FFILibrary(const char* libPath);
    static FFILibrary* From(Local<Value> value);
    ~FFILibrary();
};

class FFIDefinition
{
public:
    explicit FFIDefinition(const char* defStr);
    void readValue(int i, Local<Value> input, ffi_raw* output);
    Local<Value> wrapValue(int i, Isolate* isolate, ffi_raw* input);

protected:
    static constexpr auto ABI = FFI_DEFAULT_ABI;
    ffi_cif cif{};
    std::unique_ptr<ffi_type*[]> types;
};

class FFIFunction : public FFIDefinition
{
public:
    explicit FFIFunction(const char* defStr, void* address);
    static FFIFunction* From(Local<Value> value);
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
    static FFICallback* From(Local<Value> value);
    ~FFICallback();

protected:
    static constexpr auto FCS = sizeof(ffi_raw_closure);
    static void RawCallback(ffi_cif*, void*, ffi_raw*, void*);
    ffi_raw_closure* pfc{};
    void* address{};
};
} // namespace node::ffi

#endif // defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#endif // SRC_NODE_FFI_H_
