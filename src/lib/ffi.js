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

module.exports = internalBinding('ffi')

// function loadFunction(library, name, def) {
//   const parsed = parseDefinition(def)
//   const address = ffiFindFunction(library, def.name || name)
//   return (...args) => ffiDownCall(address, parsed, args)
// }

//
// const {
//   ffiCreateBuffer,
//   ffiCreateCallback,
//   ffiDownCall,
//   ffiFindFunction,
//   ffiFreeCallback,
//   ffiFreeLibrary,
//   ffiGetAddress,
//   ffiIs64,
//   ffiIsLE,
//   ffiIsWin,
//   ffiLoadLibrary
// } = require('node:ffi-internal')
//
// function parseMode(mode) {
//   switch (mode) {
//     case 'cdecl':
//       return 'c'
//     case 'default':
//       return ':'
//     case 'fastcall':
//       return (ffiIsWin ? 'F' : 'f')
//     case 'thiscall':
//       return (ffiIsWin ? '+' : '#')
//     case 'stdcall':
//       return 's'
//     default:
//       throw new TypeError(`unsupported calling convention: ${mode}`)
//   }
// }
//
// function parseType(type) {
//   switch (type) {
//     case 'void':
//       return 'v'
//     case 'bool':
//       return 'B'
//     case 'u8':
//       return 'C'
//     case 'i8':
//       return 'c'
//     case 'u16':
//       return 'S'
//     case 'i16':
//       return 's'
//     case 'u32':
//       return 'I'
//     case 'i32':
//       return 'i'
//     case 'u64':
//       return 'L'
//     case 'i64':
//       return 'l'
//     case 'f32':
//       return 'f'
//     case 'f64':
//       return 'd'
//     case 'usize':
//       return (ffiIs64 ? 'L' : 'I')
//     case 'isize':
//       return (ffiIs64 ? 'l' : 'i')
//     case 'pointer':
//     case 'buffer':
//     case 'function':
//       return 'p'
//     default:
//       throw new TypeError(`unsupported parameter type: ${type}`)
//   }
// }
//
// function parseTypeList(params) {
//   return params.map(parseType).join('')
// }
//
// function parseDefinition(def) {
//   return {
//     mode: parseMode(def.mode || 'default'),
//     result: parseType(def.result || 'void'),
//     signature: parseTypeList(def.parameters || [])
//   }
// }
//
//
// function pointerFunction(pointer, def) {
//   const parsed = parseDefinition(def)
//   const address = ffiGetAddress(pointer)
//   return (...args) => ffiDownCall(address, parsed, args)
// }
//
// function copyBuffer() {
// }
//
// function createArrayBuffer() {
// }
//
// function createBuffer(pointer) {
// }
//
// function createCallback(callback, def) {
//   const parsed = parseDefinition(def)
//   return ffiCreateCallback(parsed, callback)
// }
//
// function createString() {
// }
//
// function freeCallback(pointer) {
//   return ffiFreeCallback(pointer)
// }
//
// function freeLibrary(library) {
//   return ffiFreeLibrary(library)
// }
//
//
// class UnsafeCallback {
//   callback
//   definition
//   pointer
//
//   constructor(definition, callback) {
//     this.definition = definition
//     this.callback = callback
//     this.pointer = createCallback(callback, definition)
//   }
//
//   close() {
//     freeCallback(this.pointer)
//   }
//
//   ref() {
//     throw new Error('error')
//   }
//
//   unref() {
//     throw new Error('error')
//   }
//
//   static threadSafe(definition, callback) {
//     throw new Error('error')
//   }
// }
//
// class UnsafeFnPointer {
//   definition
//   pointer
//   #invoker
//
//   constructor(pointer, definition) {
//     this.pointer = pointer
//     this.definition = definition
//     this.#invoker = pointerFunction(pointer, definition)
//   }
//
//   call(...props) {
//     return this.#invoker(...props)
//   }
// }
//
// class UnsafePointer {
//   #rawPtr
//
//   constructor(value) {
//     if (typeof value === 'bigint') {
//       this.#rawPtr = value
//     }
//     throw new Error('error')
//   }
//
//   static create(value) {
//     return new UnsafePointer(value)
//   }
//
//   static equals(a, b) {
//     if (a instanceof UnsafePointer && b instanceof UnsafePointer) {
//       return a.#rawPtr === b.#rawPtr
//     }
//     return false
//   }
//
//   static of(value) {
//     if (value instanceof UnsafePointer) {
//       return value
//     }
//     if (typeof value === 'bigint') {
//       return new UnsafePointer(value)
//     }
//     throw new Error('error')
//   }
//
//   static offset(pointer, offset) {
//     if (pointer instanceof UnsafePointer) {
//       return new UnsafePointer(pointer.#rawPtr + offset)
//     }
//     throw new Error('error')
//   }
//
//   static value(pointer) {
//     if (pointer instanceof UnsafePointer) {
//       return pointer.#rawPtr
//     }
//     throw new Error('error')
//   }
// }
//
// class UnsafePointerView {
//   pointer
//   #buffer
//
//   constructor(pointer) {
//     this.pointer = pointer
//     this.#buffer = createBuffer(pointer)
//   }
//
//   getBool(offset) {
//     return this.#buffer.readInt8(offset) !== 0
//   }
//
//   getInt8(offset) {
//     return this.#buffer.readInt8(offset)
//   }
//
//   getInt16(offset) {
//     if (ffiIsLE) {
//       return this.#buffer.readInt16LE(offset)
//     } else {
//       return this.#buffer.readInt16BE(offset)
//     }
//   }
//
//   getInt32(offset) {
//     if (ffiIsLE) {
//       return this.#buffer.readInt32LE(offset)
//     } else {
//       return this.#buffer.readInt32BE(offset)
//     }
//   }
//
//   getBigInt64(offset) {
//     if (ffiIsLE) {
//       return this.#buffer.readBigInt64LE(offset)
//     } else {
//       return this.#buffer.readBigInt64BE(offset)
//     }
//   }
//
//   getUint8(offset) {
//     return this.#buffer.readUint8(offset)
//   }
//
//   getUint16(offset) {
//     if (ffiIsLE) {
//       return this.#buffer.readUint16LE(offset)
//     } else {
//       return this.#buffer.readUint16BE(offset)
//     }
//   }
//
//   getUint32(offset) {
//     if (ffiIsLE) {
//       return this.#buffer.readUint32LE(offset)
//     } else {
//       return this.#buffer.readUint32BE(offset)
//     }
//   }
//
//   getBigUint64(offset) {
//     if (ffiIsLE) {
//       return this.#buffer.readBigUint64LE(offset)
//     } else {
//       return this.#buffer.readBigUint64BE(offset)
//     }
//   }
//
//   getFloat32(offset) {
//     if (ffiIsLE) {
//       return this.#buffer.readFloatLE(offset)
//     } else {
//       return this.#buffer.readFloatBE(offset)
//     }
//   }
//
//   getFloat64(offset) {
//     if (ffiIsLE) {
//       return this.#buffer.readDoubleLE(offset)
//     } else {
//       return this.#buffer.readDoubleBE(offset)
//     }
//   }
//
//   getPointer(offset) {
//     return UnsafePointer.offset(this.pointer, offset)
//   }
//
//   copyInto(destination, offset) {
//     return copyBuffer(this.pointer, destination, offset)
//   }
//
//   getArrayBuffer(byteLength, offset) {
//     return createArrayBuffer(this.pointer, byteLength, offset)
//   }
//
//   getCString(offset) {
//     return createString(this.pointer, offset)
//   }
//
//   static copyInto(pointer, destination, offset) {
//     return copyBuffer(pointer, destination, offset)
//   }
//
//   static getArrayBuffer(pointer, byteLength, offset) {
//     return createArrayBuffer(pointer, byteLength, offset)
//   }
//
//   static getCString(pointer, offset) {
//     return createString(pointer, offset)
//   }
// }
//
// module.exports = {
//   dlopen,
//   UnsafeCallback,
//   UnsafeFnPointer,
//   UnsafePointer,
//   UnsafePointerView
// }
