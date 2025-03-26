#ifndef SRC_NODE_FFI_H_
#define SRC_NODE_FFI_H_

#if defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS

#include "ffi.h"
#include "node_binding.h"

namespace node::ffi
{
    class FFIFunction
    {
        ffi_cif ffiDef{};
        ffi_raw retVal{};
        ffi_type* retType{};
        std::unique_ptr<ffi_raw[]> argVals;
        std::unique_ptr<ffi_type**> argTypes;
        std::unique_ptr<void*[]> argPtrs;

        static ffi_type* parseType(char code);

    public:
        void initDefine(const char* defStr);
    };

    class FFILibrary
    {
    };

    // class FfiLibrary : public BaseObject
    // {
    // public:
    //     void GetAddress();
    // };
    //
    // class FfiFunction : public BaseObject
    // {
    // public:
    //     void DownCall();
    // };
    //
    // class FfiCallback : public BaseObject
    // {
    // public:
    //     void UpCall();
    // };
    //
    //
    // namespace ffi
    // {
    //     class FfiSignature : public BaseObject
    //     {
    //     public:
    //         FfiSignature(Environment* env,
    //                      Local<Object> object,
    //                      Local<BigInt> fn,
    //                      Local<BigInt> ret_type,
    //                      Local<Array> arg_types);
    //         static void New(const v8::FunctionCallbackInfo<v8::Value>& args);
    //         SET_SELF_SIZE(FfiSignature)
    //         SET_MEMORY_INFO_NAME(FfiSignature)
    //         SET_NO_MEMORY_INFO()
    //
    //         ffi_cif cif_;
    //         std::vector<ffi_type*> argv_types_;
    //         void (*fn_)();
    //     };
    //
    //     class FfiBindingData : public BaseObject
    //     {
    //     public:
    //         FfiBindingData(Realm* realm, Local<Object> wrap) : BaseObject(realm, wrap)
    //         {
    //         }
    //
    //         binding::DLib* GetLibrary(std::string fname);
    //
    //         SET_BINDING_ID(ffi_binding_data)
    //
    //         void* call_buffer;
    //
    //         SET_SELF_SIZE(FfiBindingData)
    //         SET_MEMORY_INFO_NAME(FfiBindingData)
    //         SET_NO_MEMORY_INFO()
    //
    //     private:
    //         std::map<std::string, std::unique_ptr<binding::DLib>> libraries_;
    //     };
    //
    //     void MakeCall(const v8::FunctionCallbackInfo<Value>& args);
    //     void AddSignature(const v8::FunctionCallbackInfo<Value>& args);
    //     void SetCallBuffer(const v8::FunctionCallbackInfo<Value>& args);
    //     void GetLibrary(const v8::FunctionCallbackInfo<Value>& args);
    //     void GetSymbol(const v8::FunctionCallbackInfo<Value>& args);
    //
    //     void Initialize(v8::Local<v8::Object> target,
    //                     v8::Local<v8::Value> unused,
    //                     v8::Local<v8::Context> context,
    //                     void* priv);
    // } // namespace ffi
} // namespace node::ffi

#endif  // defined(NODE_WANT_INTERNALS) && NODE_WANT_INTERNALS
#endif  // SRC_NODE_FFI_H_
