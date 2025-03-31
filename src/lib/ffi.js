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

'use strict';

const {
  CallFunction,
  CreateCallback,
  CreateFunction,
  FindSymbol,
  FreeCallback,
  FreeFunction,
  FreeLibrary,
  LoadLibrary
} = internalBinding('ffi');
const {
  bits
} = internalBinding('config');

module.exports = {
  CallFunction,
  CreateCallback,
  CreateFunction,
  FindSymbol,
  FreeCallback,
  FreeFunction,
  FreeLibrary,
  LoadLibrary,
  bits
};
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
