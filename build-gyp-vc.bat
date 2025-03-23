if not defined VCToolsVersion (
  call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64
)
gyp libffi/libffi.gyp --depth=. --generator-output=./gyp-build-ffi --format=msvs -Gmsvs_version=2022
msbuild ./gyp-build-ffi/libffi/libffi.sln -bl:./gyp-build-ffi/libffi/libffi.binlog -p:Configuration=Default -p:Platform=Win32
