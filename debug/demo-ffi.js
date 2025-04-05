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
