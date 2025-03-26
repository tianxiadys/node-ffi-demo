#include "env-inl.h"
#include "node_binding.h"
#include "v8.h"

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

    void LoadLibrary(const FunctionCallbackInfo<Value>& args)
    {
        CHECK(args[0]->IsString());
        Isolate* isolate = args.GetIsolate();
        Utf8Value libName(isolate, args[0]);
        DLib* libObj = new DLib(*libName, DLib::kDefaultFlags);
        if (libObj->Open())
        {
            args.GetReturnValue()
                .Set(External::New(isolate, libObj));
        }
        else
        {
            delete libObj;
            args.GetReturnValue()
                .SetNull();
        }
    }

    void FindSymbol(const FunctionCallbackInfo<Value>& args)
    {
        CHECK(args[0]->IsExternal());
        CHECK(args[1]->IsString());
        Isolate* isolate = args.GetIsolate();
        Utf8Value symName(isolate, args[1]);
        DLib* libObj = static_cast<DLib*>(args[0].As<External>()->Value());
        void* symAddr = libObj->GetSymbolAddress(*symName);
        if (symAddr)
        {
            args.GetReturnValue()
                .Set(External::New(isolate, symAddr));
        }
        else
        {
            args.GetReturnValue()
                .SetNull();
        }
    }

    void FreeLibrary(const FunctionCallbackInfo<Value>& args)
    {
        CHECK(args[0]->IsExternal());
        DLib* libObj = static_cast<DLib*>(args[0].As<External>()->Value());
        libObj->Close();
        delete libObj;
    }

    void Initialize(Local<Object> target,
                    Local<Value> unused,
                    Local<Context> context,
                    void* priv)
    {
        SetMethod(context, target, "LoadLibrary", LoadLibrary);
        SetMethod(context, target, "FindSymbol", FindSymbol);
        SetMethod(context, target, "FreeLibrary", FreeLibrary);
    }

    void Register(ExternalReferenceRegistry* registry)
    {
        registry->Register(LoadLibrary);
        registry->Register(FindSymbol);
        registry->Register(FreeLibrary);
    }
}

NODE_BINDING_CONTEXT_AWARE_INTERNAL(ffi, node::ffi::Initialize)
NODE_BINDING_EXTERNAL_REFERENCE(ffi, node::ffi::Register)
