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

'use strict'

const {
    TypeError
} = primordials

const ffiIs64 = true
const ffiIsWin = true

function parseMode(mode) {
    switch (mode) {
        case 'cdecl':
            return 'c'
        case 'default':
            return ':'
        case 'fastcall':
            return (ffiIsWin ? 'F' : 'f')
        case 'thiscall':
            return (ffiIsWin ? '+' : '#')
        case 'stdcall':
            return 's'
        default:
            throw new TypeError(`unsupported calling convention: ${mode}`)
    }
}

function parseType(type) {
    switch (type) {
        case 'void':
            return 'v'
        case 'bool':
            return 'B'
        case 'u8':
            return 'C'
        case 'i8':
            return 'c'
        case 'u16':
            return 'S'
        case 'i16':
            return 's'
        case 'u32':
            return 'I'
        case 'i32':
            return 'i'
        case 'u64':
            return 'L'
        case 'i64':
            return 'l'
        case 'f32':
            return 'f'
        case 'f64':
            return 'd'
        case 'usize':
            return (ffiIs64 ? 'L' : 'I')
        case 'isize':
            return (ffiIs64 ? 'l' : 'i')
        case 'pointer':
        case 'buffer':
        case 'function':
            return 'p'
        default:
            throw new TypeError(`unsupported parameter type: ${type}`)
    }
}

function parseTypeList(params) {
    return params.map(parseType).join('')
}

function parseDefinition(def, name) {
    return {
        name: (def.name || name),
        mode: parseMode(def.mode || 'default'),
        result: parseType(def.result || 'void'),
        signature: parseTypeList(def.parameters || [])
    }
}

function loadLibrary(filename) {
    throw new Error('error')
}

function loadFunction(library, definition, name) {
    throw new Error('error')
}

function pointerFunction(pointer, definition) {
    throw new Error('error')
}

function callbackFunction(callback, definition) {
    throw new Error('error')
}

function freeLibrary(library) {
    throw new Error('error')
}

function dlopen(filename, defMap) {
    const symbols = {}
    const library = loadLibrary(filename)
    for (const name in defMap) {
        symbols[name] = loadFunction(library, defMap[name], name)
    }
    return {
        symbols,
        close() {
            freeLibrary(library)
        }
    }
}

class UnsafeCallback {
    callback
    definition
    pointer

    constructor(definition, callback) {
        this.definition = definition
        this.callback = callback
        this.pointer = callbackFunction(callback, definition)
    }

    close() {
        throw new Error('error')
    }

    ref() {
        throw new Error('error')
    }

    unref() {
        throw new Error('error')
    }

    static threadSafe(definition, callback) {
        throw new Error('error')
    }
}

class UnsafeFnPointer {
    definition
    pointer
    #invoker

    constructor(pointer, definition) {
        this.pointer = pointer
        this.definition = definition
        this.#invoker = pointerFunction(pointer, definition)
    }

    call(...props) {
        return this.#invoker(...props)
    }
}

class UnsafePointer {
    #rawPtr

    constructor(value) {
        if (typeof value === 'bigint') {
            this.#rawPtr = value
        }
        throw new Error('error')
    }

    static create(value) {
        return new UnsafePointer(value)
    }

    static equals(a, b) {
        if (a instanceof UnsafePointer && b instanceof UnsafePointer) {
            return a.#rawPtr === b.#rawPtr
        }
        return false
    }

    static of(value) {
        if (value instanceof UnsafePointer) {
            return value
        }
        if (typeof value === 'bigint') {
            return new UnsafePointer(value)
        }
        throw new Error('error')
    }

    static offset(pointer, offset) {
        if (pointer instanceof UnsafePointer) {
            return new UnsafePointer(pointer.#rawPtr + offset)
        }
        throw new Error('error')
    }

    static value(pointer) {
        if (pointer instanceof UnsafePointer) {
            return pointer.#rawPtr
        }
        throw new Error('error')
    }
}

class UnsafePointerView {
    pointer

    constructor(pointer) {
        throw new Error('error')
    }

    copyInto(destination, offset) {
        throw new Error('error')
    }

    getBool(offset) {
        throw new Error('error')
    }

    getInt8(offset) {
        throw new Error('error')
    }

    getInt16(offset) {
        throw new Error('error')
    }

    getInt32(offset) {
        throw new Error('error')
    }

    getBigInt64(offset) {
        throw new Error('error')
    }

    getUint8(offset) {
        throw new Error('error')
    }

    getUint16(offset) {
        throw new Error('error')
    }

    getUint32(offset) {
        throw new Error('error')
    }

    getBigUint64(offset) {
        throw new Error('error')
    }

    getFloat32(offset) {
        throw new Error('error')
    }

    getFloat64(offset) {
        throw new Error('error')
    }

    getArrayBuffer(byteLength, offset) {
        throw new Error('error')
    }

    getPointer(offset) {
        throw new Error('error')
    }

    getCString(offset) {
        throw new Error('error')
    }

    static copyInto(pointer, destination, offset) {
        throw new Error('error')
    }

    static getArrayBuffer(pointer, byteLength, offset) {
        throw new Error('error')
    }

    static getCString(pointer, offset) {
        throw new Error('error')
    }
}

module.exports = {
    dlopen,
    UnsafeCallback,
    UnsafeFnPointer,
    UnsafePointer,
    UnsafePointerView
}
