@echo off

rem if not defined VCToolsVersion (
rem   call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64
rem )
rem gyp libffi.gyp --depth=. --generator-output=../gyp-build-ffi --format=msvs -Gmsvs_version=2022
rem msbuild ../gyp-build-ffi/libffi.sln -bl:../gyp-build-ffi/libffi.binlog -p:Configuration=Default -p:Platform=Win32

