const {
  CallFunction,
  CreateCallback,
  CreateFunction,
  FindSymbol,
  FreeCallback,
  FreeFunction,
  FreeLibrary,
  LoadLibrary
} = require('node:ffi')

const gcCallback = new FinalizationRegistry(FreeCallback)
const gcFunction = new FinalizationRegistry(FreeFunction)
const gcLibrary = new FinalizationRegistry(FreeLibrary)

