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
  Error,
  FinalizationRegistry
} = primordials;
const {
  CallInvoker,
  CreateBuffer,
  CreateCallback,
  CreateInvoker,
  FindSymbol,
  FreeCallback,
  FreeInvoker,
  FreeLibrary,
  GetAddress,
  LoadLibrary,
  SysIs64,
  SysIsLE
} = internalBinding('ffi');
const {
  clearInterval,
  setInterval
} = require('timers');

const gcInvoker = new FinalizationRegistry(FreeInvoker);
const is64 = SysIs64();
const isLE = SysIsLE();

function parseType(type) {
  switch (type) {
    case 'void':
      return 'v';
    case 'u8':
      return 'C';
    case 'i8':
      return 'c';
    case 'u16':
      return 'S';
    case 'i16':
      return 's';
    case 'u32':
      return 'I';
    case 'bool':
    case 'i32':
      return 'i';
    case 'u64':
      return 'L';
    case 'i64':
      return 'l';
    case 'f32':
      return 'f';
    case 'usize':
      return (is64 ? 'L' : 'I');
    case 'isize':
      return (is64 ? 'l' : 'i');
    case 'pointer':
    case 'buffer':
    case 'function':
      return 'p';
    default:
      throw new Error('bad type');
  }
}

function parseDefStr(defObj) {
  const temp = [];
  temp.push(parseType(defObj.result));
  for (const param of defObj.parameters) {
    temp.push(parseType(param));
  }
  return temp.join('');
}

function createInvoker(defObj, address, refer) {
  const defStr = parseDefStr(defObj);
  const invoker = CreateInvoker(address, defStr);
  gcInvoker.register(refer, invoker, refer);
  return (...args) => CallInvoker(invoker, ...args);
}

function dlopen(filename, defMap) {
  return new UnsafeLibrary(filename, defMap);
}

function getAddress(value) {
  if (typeof value === 'bigint') {
    return value;
  } else {
    return GetAddress(value);
  }
}

class UnsafeLibrary {
  symbols;
  #library;

  constructor(filename, defMap) {
    const symbols = {};
    const library = LoadLibrary(filename);
    for (const name in defMap) {
      const defObj = defMap[name];
      const address = FindSymbol(library, defObj.name || name);
      if (address) {
        symbols[name] = createInvoker(defObj, address, this);
      } else if (!defObj.optional) {
        throw new Error('bad symbol');
      }
    }
    this.symbols = symbols;
    this.#library = library;
  }

  close() {
    FreeLibrary(this.#library);
  }
}

class UnsafeCallback {
  callback;
  definition;
  pointer;
  #callback;
  #timeout;

  constructor(defObj, callback) {
    const defStr = parseDefStr(defObj);
    [this.#callback, this.pointer] = CreateCallback(defStr, callback);
    this.callback = callback;
    this.definition = defObj;
    this.#timeout = 0;
  }

  close() {
    FreeCallback(this.#callback);
  }

  ref() {
    if (!this.#timeout) {
      this.#timeout = setInterval(() => 0, 2 ** 30);
    }
    return this;
  }

  unref() {
    if (this.#timeout) {
      clearInterval(this.#timeout);
      this.#timeout = 0;
    }
    return this;
  }
}

class UnsafeFnPointer {
  call;
  definition;
  pointer;

  constructor(pointer, defObj) {
    this.call = createInvoker(defObj, pointer, this);
    this.definition = defObj;
    this.pointer = pointer;
  }
}

class UnsafePointer {
  static create(value) {
    return getAddress(value);
  }

  static equals(value1, value2) {
    const int1 = getAddress(value1);
    const int2 = getAddress(value2);
    return int1 === int2;
  }

  static of(value) {
    return getAddress(value);
  }

  static offset(pointer, offset) {
    const int1 = getAddress(pointer);
    const int2 = BigInt(offset);
    return int1 + int2;
  }

  static value(value) {
    return getAddress(value);
  }
}

//
// class UnsafePointerView {
//   pointer;
//   #buffer;
//
//   constructor(pointer) {
//     this.pointer = pointer;
//     this.#buffer = CreateBuffer(pointer);
//   }
//
//   getBool(offset) {
//     return this.#buffer.readInt8(offset) !== 0;
//   }
//
//   getInt8(offset) {
//     return this.#buffer.readInt8(offset);
//   }
//
//   getInt16(offset) {
//     if (isLE) {
//       return this.#buffer.readInt16LE(offset);
//     } else {
//       return this.#buffer.readInt16BE(offset);
//     }
//   }
//
//   getInt32(offset) {
//     if (isLE) {
//       return this.#buffer.readInt32LE(offset);
//     } else {
//       return this.#buffer.readInt32BE(offset);
//     }
//   }
//
//   getBigInt64(offset) {
//     if (isLE) {
//       return this.#buffer.readBigInt64LE(offset);
//     } else {
//       return this.#buffer.readBigInt64BE(offset);
//     }
//   }
//
//   getUint8(offset) {
//     return this.#buffer.readUint8(offset);
//   }
//
//   getUint16(offset) {
//     if (isLE) {
//       return this.#buffer.readUint16LE(offset);
//     } else {
//       return this.#buffer.readUint16BE(offset);
//     }
//   }
//
//   getUint32(offset) {
//     if (isLE) {
//       return this.#buffer.readUint32LE(offset);
//     } else {
//       return this.#buffer.readUint32BE(offset);
//     }
//   }
//
//   getBigUint64(offset) {
//     if (isLE) {
//       return this.#buffer.readBigUint64LE(offset);
//     } else {
//       return this.#buffer.readBigUint64BE(offset);
//     }
//   }
//
//   getFloat32(offset) {
//     if (isLE) {
//       return this.#buffer.readFloatLE(offset);
//     } else {
//       return this.#buffer.readFloatBE(offset);
//     }
//   }
//
//   getFloat64(offset) {
//     if (isLE) {
//       return this.#buffer.readDoubleLE(offset);
//     } else {
//       return this.#buffer.readDoubleBE(offset);
//     }
//   }
//
//   getPointer(offset) {
//     return UnsafePointer.offset(this.pointer, offset);
//   }
//
//   copyInto(destination, offset) {
//     return copyBuffer(this.pointer, destination, offset);
//   }
//
//   getArrayBuffer(byteLength, offset) {
//     return CreateBuffer(this.pointer, byteLength, offset);
//   }
//
//   getCString(offset) {
//     return createString(this.pointer, offset);
//   }
//
//   static copyInto(pointer, destination, offset) {
//     return copyBuffer(pointer, destination, offset);
//   }
//
//   static getArrayBuffer(pointer, byteLength, offset) {
//     return CreateBuffer(pointer, byteLength, offset);
//   }
//
//   static getCString(pointer, offset) {
//     return createString(pointer, offset);
//   }
// }

module.exports = {
  dlopen,
  UnsafeCallback,
  UnsafeFnPointer,
  UnsafePointer
};
