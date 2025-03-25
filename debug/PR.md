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

|            | Windows | Linux | Mac  | Other System |
|------------|---------|-------|------|--------------|
| x86        | NO      | YES   |      | ToDo         |
| x64        | YES     | YES   | YES? | ToDo         |
| ARM32      | YES     | YES   |      | ToDo         |
| ARM64      | YES     | YES   | YES? | ToDo         |
| ARM-EC     | NO      |       |      |              |
| Other Arch |         | ToDo  |      | ToDo         |

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
4. Unfortunately, I do not have access to a Mac device,
   so I was unable to test this in a real environment.
   However, it should probably work.
   By the way, I’ve already ordered a Mac Mini.
   Thanks to Apple, it’s truly an amazing device.
   Even so, I have never used macOS before,
   so it might take some time to complete this test.
5. Support for other architectures and systems will be addressed in future PRs.

---
In Deno's implementation,
There are two APIs that confuse me and are complex to implement,
so I didn’t implement them.
The first is `UnsafeCallback.threadSafe`,
and the second is the `nonblocking` option in the function signature.
These are seem more suitable for third-party libraries rather than being included in the core code.
What does everyone think?
if necessary, they can be added in future PRs.

