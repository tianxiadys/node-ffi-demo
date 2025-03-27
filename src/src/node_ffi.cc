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
#include "node_binding.h"
#include "node_ffi.h"
#include "v8.h"

namespace node::ffi
{
    void* GetAddress(const Local<Value>& value)
    {
        if (value->IsExternal())
        {
            return value.As<External>()->Value();
        }
        if (value->IsArrayBuffer())
        {
            return value.As<ArrayBuffer>()->Data();
        }
        return nullptr;
    }

    FFIDefinition::FFIDefinition(const char* defStr)
    {
        const auto size = strlen(defStr);
        if (size < 1)
        {
            UNREACHABLE("Bad defStr size");
        }
        types = std::make_unique<ffi_type*[]>(size);
        for (int i = 0; i < size; i++)
        {
            //These field definitions refer to dyncall
            switch (defStr[i])
            {
            case 'v':
                types[i] = &ffi_type_void;
                break;
            case 'C':
                types[i] = &ffi_type_uint8;
                break;
            case 'c':
                types[i] = &ffi_type_sint8;
                break;
            case 'S':
                types[i] = &ffi_type_uint16;
                break;
            case 's':
                types[i] = &ffi_type_sint16;
                break;
            case 'I':
                types[i] = &ffi_type_uint32;
                break;
            case 'i':
                types[i] = &ffi_type_sint32;
                break;
            case 'L':
                types[i] = &ffi_type_uint64;
                break;
            case 'l':
                types[i] = &ffi_type_sint64;
                break;
            case 'f':
                types[i] = &ffi_type_float;
                break;
            case 'p':
                types[i] = &ffi_type_pointer;
                break;
            default:
                UNREACHABLE("Bad FFI type");
            }
        }
        if (ffi_prep_cif(&cif, ABI, size - 1, types[0], &types[1]) != FFI_OK)
        {
            UNREACHABLE("ffi_prep_cif Failed");
        }
    }

    FFIFunction::FFIFunction(const char* defStr, void* address)
        : FFIDefinition(defStr)
    {
        invoker = FFI_FN(address);
        datas = std::make_unique<ffi_raw[]>(cif.nargs);
    }

    void FFIFunction::setParam(const int i, const Local<Value>& value)
    {
        const auto type = cif.arg_types[i];
        if (type == &ffi_type_void)
        {
            datas[i].uint = 0;
        }
        else if (type == &ffi_type_uint8
            || type == &ffi_type_uint16
            || type == &ffi_type_uint32)
        {
            datas[i].uint = value.As<Number>()->Value();
        }
        else if (type == &ffi_type_sint8
            || type == &ffi_type_sint16
            || type == &ffi_type_sint32)
        {
            datas[i].sint = value.As<Number>()->Value();
        }
        else if (type == &ffi_type_float)
        {
            datas[i].flt = value.As<Number>()->Value();
        }
        else if (type == &ffi_type_uint64)
        {
            datas[i].uint = value.As<BigInt>()->Uint64Value();
        }
        else if (type == &ffi_type_sint64)
        {
            datas[i].sint = value.As<BigInt>()->Int64Value();
        }
        else if (type == &ffi_type_pointer)
        {
            datas[i].ptr = GetAddress(value);
        }
        else
        {
            UNREACHABLE("Bad FFI type");
        }
    }

    void FFIFunction::doInvoke(ffi_raw* result)
    {
        ffi_raw_call(&cif, invoker, result, datas.get());
    }

    FFICallback::FFICallback(const char* defStr)
        : FFIDefinition(defStr)
    {
        const auto alloc = ffi_closure_alloc(FCS, &address);
        if (!alloc)
        {
            UNREACHABLE("ffi_closure_alloc Failed");
        }
        pfc = static_cast<ffi_closure*>(alloc);
        if (ffi_prep_closure(pfc, &cif, RawCallback, this) != FFI_OK)
        {
            UNREACHABLE("ffi_prep_closure Failed");
        }
    }

    Local<External> FFICallback::getAddress(Isolate* isolate) const
    {
        return External::New(isolate, address);
    }

    void FFICallback::RawCallback(ffi_cif*, void* ret, void** args, void* data)
    {
        const auto self = static_cast<FFICallback*>(data);
    }

    FFICallback::~FFICallback()
    {
        if (pfc)
        {
            ffi_closure_free(pfc);
        }
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
