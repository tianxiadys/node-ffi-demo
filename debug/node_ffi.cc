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
    FFIFunction::FFIFunction(const char* defStr)
    {
        const auto defLen = strlen(defStr);
        if (defLen < 1)
        {
            //UNREACHABLE("Bad defStr size");
        }
        typeArr = std::make_unique<ffi_type*[]>(defLen);
        for (int i = 0; i < defLen; i++)
        {
            typeArr[i] = parseType(defStr[i]);
        }
        const auto ffiRet = ffi_prep_cif
            (&ffiCif, FFI_DEFAULT_ABI, defLen - 1, typeArr[0], &typeArr[1]);
        if (ffiRet != FFI_OK)
        {
            //UNREACHABLE("ffi_prep_cif Failed");
        }
    }

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
            //UNREACHABLE("Bad FFI type");
            return nullptr;
        }
    }
}
