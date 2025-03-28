const ffi = require('node:ffi')
console.log(ffi)
const lib = ffi.LoadLibrary('user32')
console.log(lib)
const MessageBoxW = ffi.FindSymbol(lib, 'MessageBoxW')
console.log(MessageBoxW)
const call = ffi.CreateFunction(MessageBoxW, 'ipppI')
console.log(call)

const buff = new ArrayBuffer(10)
const buff2 = new Uint16Array(buff)
buff2[0] = '哈'.charCodeAt(0)

const ret = ffi.CallFunction(call, null, buff, buff, 0)
console.log(ret)

