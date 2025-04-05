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
} = require('node:ffi');

const gcCallback = new FinalizationRegistry(FreeCallback);
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

class UnsafeLibrary {
  symbols = {};
  #library;

  constructor(filename, defMap) {
    this.#library = LoadLibrary(filename);
    for (const name in defMap) {
      const defObj = defMap[name];
      const address = FindSymbol(this.#library, defObj.name || name);
      if (address) {
        this.symbols[name] = createInvoker(defObj, address, this);
      } else if (defObj.optional) {
        return () => {
          throw new Error('bad symbol');
        };
      } else {
        throw new Error('bad symbol');
      }
    }
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

  constructor(defObj, callback) {
    this.definition = defObj;
    this.callback = callback;
    const defStr = parseDefStr(defObj.result, defObj.parameters);
    const result = CreateCallback(defStr, callback);
    this.#callback = result[0];
    this.pointer = UnsafePointer.create(result[1]);
    gcCallback.register(this, this.#callback, this);
  }

  close() {
    FreeCallback(this.#callback);
    gcCallback.unregister(this);
  }
}

class UnsafeFnPointer {
  call;
  definition;
  pointer;

  constructor(pointer, defObj) {
    this.pointer = pointer;
    this.definition = defObj;
    this.call = createInvoker(defObj, pointer, this);
  }
}

//
// class UnsafePointer {
//   static create(value) {
//     return UnsafePointer.value(value);
//   }
//
//   static equals(value1, value2) {
//     const int1 = UnsafePointer.value(value1);
//     const int2 = UnsafePointer.value(value2);
//     return int1 === int2;
//   }
//
//   static of(value) {
//     return UnsafePointer.value(value);
//   }
//
//   static offset(pointer, offset) {
//     const int1 = UnsafePointer.value(pointer);
//     const int2 = BigInt(offset);
//     return int1 + int2;
//   }
//
//   static value(value) {
//     if (typeof value === 'bigint') {
//       return value;
//     } else {
//       return GetAddress(value);
//     }
//   }
// }
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
  a2.symbols.EnumWindows(UnsafePointer.value(a1.pointer), 3);
  console.log(a1);
  a1 = null;
  a2 = null;
  gc();
  gc();
  gc();
})();
