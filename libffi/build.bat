call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64

rem gyp libffi.gyp --depth=. --generator-output=../gyp-build-1 -f=msvs

rem msbuild ../gyp-build-1/libffi.sln /t:libffi -p:Configuration=Default -p:Platform=Win32
call
