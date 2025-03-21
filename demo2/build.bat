if not defined VCToolsVersion (
  call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64
)
gyp demo2.gyp --depth=. --generator-output=../gyp-build-2 --format=msvs -Gmsvs_version=2022
msbuild ../gyp-build-2/demo2.sln -bl:../gyp-build-2/demo2.binlog -p:Configuration=Default -p:Platform=Win32
