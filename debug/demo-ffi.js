const {
  CallFunction,
  CreateCallback,
  CreateFunction,
  FindSymbol,
  FreeCallback,
  FreeFunction,
  FreeLibrary,
  LoadLibrary,
  bits
} = require('node:ffi');

const gcCallback = new FinalizationRegistry(val => {
  console.log(`gcCallback:${val}`);
  FreeCallback(val);
});
const gcFunction = new FinalizationRegistry(val => {
  console.log(`gcFunction:${val}`);
  FreeFunction(val);
});
const gcLibrary = new FinalizationRegistry(val => {
  console.log(`gcLibrary:${val}`);
  FreeLibrary(val);
});

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
      throw new TypeError('bad type');
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

function createSymbol(defObj, name, library) {
  const address = FindSymbol(library, defObj.name || name);
  if (address) {
    const defStr = parseDefStr(defObj.result, defObj.parameters);
    const method = CreateFunction(address, defStr);
    const callable = (...args) => CallFunction(method, ...args);
    gcFunction.register(callable, method, callable);
    return callable;
  } else if (defObj.optional) {
    return () => throw new TypeError('bad symbol');
  } else {
    throw new TypeError('bad symbol');
  }
}

class UnsafeLibrary {
  symbols = {};
  #library;

  constructor(filename, defMap) {
    this.#library = LoadLibrary(filename);
    for (const name in defMap) {
      this.symbols[name] = createSymbol(defMap[name], name, this.#library);
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
