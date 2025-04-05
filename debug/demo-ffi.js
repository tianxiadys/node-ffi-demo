const {
  dlopen,
  UnsafeCallback,
  UnsafeFnPointer
} = require('node:ffi');

let a1 = new UnsafeCallback({
  result: 'i32',
  parameters: ['pointer', 'u64']
}, (hWnd, lParam) => {
  console.log('hWnd', hWnd, 'lParam', lParam);
  return 1n;
});
let a2 = dlopen('user32', {
  EnumWindows: {
    result: 'i32',
    parameters: ['pointer', 'u64']
  }
});
a2.symbols.EnumWindows(a1.pointer, 3);
console.log(a1);
