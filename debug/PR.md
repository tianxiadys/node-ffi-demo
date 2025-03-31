Currently, FFI does not support all the platforms that Node.js supports.
To avoid compilation failures on unsupported platforms and to prevent confusion for developers,
I have added a compile-time flag, which is disabled by default.
Here is an example of the configure commands:

```bash
./configure.py --enable-ffi
```

Or you are on the Windows platform.

```bash
./vcbuild.bat ffi
```

This is an experimental feature.
You must run Node with the `--experimental-ffi` flag to use it.
Additionally, it is a security-sensitive feature,
so you also need to use the `--allow-ffi` flag.
Here is a command-line example:

```bash
node --experimental-ffi --allow-ffi demo.js
```

---
The core of this feature relies on calling the `libffi` library.
Referencing `libffi` is challenging because it heavily depends on `automake` and has poor support for MSVC.
To successfully integrate this library, I made some adjustments.
First, I streamlined the library's files by removing parts we don't currently need.
These can be added back in as needed.
Next, I created a separate `fixed` folder where I wrote files:
`ffi.h`, `ffi.c`, `ffiasm.S`, `fficonfig.h` and `ffitarget.h`.
These files use `#if` macros to handle most of the work that would normally be done by `automake`.
Upgrading `libffi` in the future is both necessary and entirely feasible.
I only added files without modifying any of `libffi`'s existing files.
When updating to a newer version of `libffi`,
you simply need to replace the corresponding files.

---
Here is the system and CPU support status:

|            | Windows | Linux | Mac | Other System |
|------------|---------|-------|-----|--------------|
| x86        | NO      | YES   |     | ToDo         |
| x64        | YES     | YES   | YES | ToDo         |
| ARM32      | YES     | YES   |     | ToDo         |
| ARM64      | YES     | YES   | YES | ToDo         |
| ARM-EC     | NO      |       |     |              |
| Other Arch |         | ToDo  |     | ToDo         |

1. Blank spaces in the table indicate the absence of such combinations.
   Windows does not support the fifth type of CPU,
   and Mac only supports x64 and ARM64.
2. Windows x86 is the most unique platform because it has numerous calling conventions,
   which are an important part of a function's signature.
   However, our JS API does not have a field to specify the calling convention.
   Fortunately, this platform is no longer actively supported by Node.js,
   so we can reasonably abandon it.
3. The hybrid architecture ([Windows ARM-EC](https://learn.microsoft.com/en-us/windows/arm/arm64ec)) is a crazy idea,
   and I’m not sure whether this technology is widely used.
   Undoubtedly, it presents significant challenges for FFI.
   Currently, it is not supported and likely won’t be in the future either.
4. Support for other architectures and systems will be addressed in future PRs.

---
For @aapoalas:
It seems that a `double` type field is missing in `ffi_raw`.
Was this intentionally designed?
Although this issue can be resolved by forcibly casting the pointer type,
I didn't do so because I suspect there might be some traps I'm unaware of waiting for me.

---
For @atgreen:
These two features are `UnsafeCallback.threadSafe` and the `nonblocking` option.
They seem to work as a pair;
at the very least, the `threadSafe` method should not be able to exist independently of `nonblocking`.
The most complex callback scenarios I can think of
are the Win32 window procedure callback and APC invocation.
The former involves registering a callback method in `RegisterWndClass`,
and later, during the message loop,
the thread processes the window procedure by calling `DispatchMessage`.
The latter involves registering a callback method in `ReadFileEx`,
and subsequently, the APC callback is entered internally within the `SleepEx` method.
In any case, the prerequisite for the current thread to enter a callback function
is that the thread must call a certain method,
and this method will internally locate the callback function pointer recorded somewhere,
and then enter the callback function.
A thread cannot arbitrarily enter a callback function at any location;
perhaps only Linux's `signal` method has such magical capabilities.
In summary, `threadSafe` seems to apply only to certain specific scenarios.
For example, an independent thread outside of the Node.js event loop executes some kind of loop,
and at a certain point in the loop,
it sends a message to the Node.js main thread.
Wouldn't such a requirement be more suitable for implementation
in a third-party library rather than in the core code of Node.js or Deno.js?

---
I can't wait to share this module with everyone!
The following tasks have not been completed yet,
but perhaps they can be ignored in this PR and completed in future PRs:

1. Documentation for the ffi module (nightly users can refer to Deno.js's documentation).
2. Support only for Windows, Linux, Mac platforms, and certain CPU architectures.
3. Auto-update scripts for libffi.
4. Unit test code and benchmark test code
5. `UnsafeCallback.threadSafe` and the `nonblocking` option.
6. The `double` type is not supported.
7. Other details I haven't thought of yet.
