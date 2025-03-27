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

#include "node_ffi.h"

namespace node::ffi
{
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
            case 'd':
                types[i] = &ffi_type_double;
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
        args = std::make_unique<void*[]>(cif.nargs);
        for (int i = 0; i < cif.nargs; i++)
        {
            args[i] = &datas[i];
        }
    }

    void FFIFunction::setParam(const int i, const void* ptr)
    {
        memcpy(datas[i].data, ptr, cif.arg_types[i]->size);
    }

    void FFIFunction::doInvoke(ffi_raw* result)
    {
        ffi_call(&cif, invoker, result, args.get());
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
}
