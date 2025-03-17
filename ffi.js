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

class UnsafeLibrary {
  symbols

  constructor(filename, definition) {
  }

  close() {
  }
}

class UnsafeCallback {
  callback
  definition
  pointer

  constructor(definition, callback) {
  }

  close() {
  }

  ref() {
  }

  unref() {
  }

  static threadSafe(definition, callback) {
    throw new Error('error')
  }
}

class UnsafeFnPointer {
  definition
  pointer

  constructor(pointer, definition) {
  }

  call(...props) {
  }
}

class UnsafePointer {
  #rawPtr

  constructor(rawPtr) {
    if (typeof rawPtr === 'bigint') {
      this.#rawPtr = rawPtr
    } else {
      throw new Error('error')
    }
  }

  static create(rawPtr) {
    return new UnsafePointer(rawPtr)
  }

  static equals(a, b) {
    if (a instanceof UnsafePointer && b instanceof UnsafePointer) {
      return a.#rawPtr === b.#rawPtr
    } else {
      return false
    }
  }

  static of(value) {
  }

  static offset(pointer, offset) {
    if (pointer instanceof UnsafePointer) {
      return new UnsafePointer(pointer.#rawPtr + offset)
    } else {
      throw new Error('error')
    }
  }

  static value(pointer) {
    if (pointer instanceof UnsafePointer) {
      return pointer.#rawPtr
    } else {
      throw new Error('error')
    }
  }
}

class UnsafePointerView {
  pointer

  constructor(pointer) {
  }

  copyInto(destination, offset) {
  }

  getBool(offset) {
  }

  getInt8(offset) {
  }

  getInt16(offset) {
  }

  getInt32(offset) {
  }

  getBigInt64(offset) {
  }

  getUint8(offset) {
  }

  getUint16(offset) {
  }

  getUint32(offset) {
  }

  getBigUint64(offset) {
  }

  getFloat32(offset) {
  }

  getFloat64(offset) {
  }

  getArrayBuffer(byteLength, offset) {
  }

  getPointer(offset) {
  }

  getCString(offset) {
  }

  static copyInto(pointer, destination, offset) {
  }

  static getArrayBuffer(pointer, byteLength, offset) {
  }

  static getCString(pointer, offset) {
  }
}

module.exports = {
  dlopen(filename, definition) {
    return new UnsafeLibrary(filename, definition)
  },
  UnsafeCallback,
  UnsafeFnPointer,
  UnsafePointer,
  UnsafePointerView,
}
