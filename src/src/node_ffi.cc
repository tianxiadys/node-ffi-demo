// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "env-inl.h"
#include "node_ffi.h"
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

    ffi_type* FFIFunction::parseType(char code)
    {
        switch (code)
        {
        case 'v':
            return &ffi_type_void;
        case 'C':
            return &ffi_type_uint8;
        case 'c':
            return &ffi_type_sint8;
        case 'S':
            return &ffi_type_uint16;
        case 's':
            return &ffi_type_sint16;
        case 'I':
            return &ffi_type_uint32;
        case 'B':
        case 'i':
            return &ffi_type_sint32;
        case 'L':
            return &ffi_type_uint64;
        case 'l':
            return &ffi_type_sint64;
        case 'f':
            return &ffi_type_float;
        case 'd':
            return &ffi_type_double;
        case 'p':
            return &ffi_type_pointer;
        default:
            UNREACHABLE("Bad FFI type");
        }
    }

    void FFIFunction::initDefine(const char* defStr)
    {
        const auto defLen = strlen(defStr);
        const auto valLen = defLen - 1;
        if (defLen < 1)
        {
            UNREACHABLE("Bad defStr size");
        }
        if (valLen > 0)
        {
            argVals = std::make_unique<ffi_raw[]>(valLen);
            argTypes = std::make_unique<ffi_type*[]>(valLen);
            argPtrs = std::make_unique<void*[]>(valLen);
        }
        else
        {
            argVals = nullptr;
            argTypes = nullptr;
            argPtrs = nullptr;
        }
        retType = parseType(defStr[0]);
        for (int i = 0; i < valLen; i++)
        {
            argTypes[i] = parseType(defStr[i + 1]);
            argPtrs[i] = &argVals[i];
        }
        ffi_prep_cif(&ffiDef, FFI_DEFAULT_ABI, valLen, retType, argTypes);
    }

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
        SetMethod(context, target, "FindSymbol", FindSymbol);
        SetMethod(context, target, "FreeLibrary", FreeLibrary);
        SetMethod(context, target, "LoadLibrary", LoadLibrary);
    }

    void Register(ExternalReferenceRegistry* registry)
    {
        registry->Register(FindSymbol);
        registry->Register(FreeLibrary);
        registry->Register(LoadLibrary);
    }
}

NODE_BINDING_CONTEXT_AWARE_INTERNAL(ffi, node::ffi::Initialize)
NODE_BINDING_EXTERNAL_REFERENCE(ffi, node::ffi::Register)
