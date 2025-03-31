const {
  CallFunction,
  CreateBuffer,
  CreateCallback,
  CreateFunction,
  FindSymbol,
  FreeCallback,
  FreeFunction,
  FreeLibrary,
  GetAddress,
  LoadLibrary,
  bits
} = require('node:ffi');

const gcCallback = new FinalizationRegistry(FreeCallback);
const gcFunction = new FinalizationRegistry(FreeFunction);
const gcLibrary = new FinalizationRegistry(FreeLibrary);

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
      return (bits === 64 ? 'L' : 'I');
    case 'isize':
      return (bits === 64 ? 'l' : 'i');
    case 'pointer':
    case 'buffer':
    case 'function':
      return 'p';
    default:
      throw new Error('bad type');
  }
}

function parseDefStr(result, parameters) {
  const temp = [];
  temp.push(parseType(result));
  for (const type of parameters) {
    temp.push(parseType(type));
  }
  return temp.join('');
}

function createSymbol(defObj, name, library, par) {
  const address = FindSymbol(library, defObj.name || name);
  if (address) {
    const defStr = parseDefStr(defObj.result, defObj.parameters);
    const method = CreateFunction(address, defStr);
    gcFunction.register(par, method, par);
    return (...args) => CallFunction(method, ...args);
  } else if (defObj.optional) {
    return () => {
      throw new Error('bad symbol');
    };
  } else {
    throw new Error('bad symbol');
  }
}

class UnsafeLibrary {
  symbols = {};
  #library;

  constructor(filename, defMap) {
    this.#library = LoadLibrary(filename);
    for (const name in defMap) {
      this.symbols[name] = createSymbol(defMap[name], name, this.#library, this);
    }
    gcLibrary.register(this, this.#library, this);
  }

  close() {
    FreeLibrary(this.#library);
    gcLibrary.unregister(this);
  }
}


class UnsafeCallback {
  callback;
  definition;
  pointer;
  #callback;

  constructor(definition, callback) {
    this.definition = definition;
    this.callback = callback;
    const defStr = parseDefStr(definition.result, definition.parameters);
    const result = CreateCallback(defStr, callback);
    this.#callback = result[0];
    this.pointer = result[1];
    gcCallback.register(this, this.#callback, this);
  }

  close() {
    FreeCallback(this.#callback);
    gcCallback.unregister(this);
  }
}

class UnsafeFnPointer {
  definition;
  pointer;
  #invoker;

  constructor(pointer, definition) {
    this.pointer = pointer;
    this.definition = definition;
    const defStr = parseDefStr(definition.result, definition.parameters);
    this.#invoker = CreateFunction(pointer, defStr);
    gcFunction.register(this, this.#invoker, this);
  }

  call(...props) {
    return CallFunction(this.#invoker, ...props);
  }
}

class UnsafePointer {
  #rawPtr;

  constructor(value) {
    if (typeof value === 'bigint') {
      this.#rawPtr = value;
    } else {
      this.#rawPtr = GetAddress(value);
    }
  }

  static create(value) {
    return new UnsafePointer(value);
  }

  static equals(value1, value2) {
    const int1 = UnsafePointer.value(value1);
    const int2 = UnsafePointer.value(value2);
    return int1 === int2;
  }

  static of(value) {
    if (value instanceof UnsafePointer) {
      return value;
    } else {
      return new UnsafePointer(value);
    }
  }

  static offset(pointer, offset) {
    const int1 = UnsafePointer.value(pointer);
    const int2 = BigInt(offset);
    return new UnsafePointer(int1 + int2);
  }

  static value(pointer) {
    if (pointer instanceof UnsafePointer) {
      return pointer.#rawPtr;
    } else {
      return GetAddress(pointer);
    }
  }
}

//debug
(() => {
  let a1 = new UnsafeCallback({
    result: 'i32',
    parameters: ['pointer', 'u64']
  }, (hWnd, lParam) => {
    console.log('hWnd', hWnd, 'lParam', lParam);
    return 1;
  });
  let a2 = new UnsafeLibrary('user32', {
    EnumWindows: {
      result: 'i32',
      parameters: ['pointer', 'u64']
    }
  });
  a2.symbols.EnumWindows(a1.pointer, 3);
  a1 = null;
  a2 = null;
  gc();
  gc();
  gc();
})();
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
