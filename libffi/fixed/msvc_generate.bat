@echo off

if %VSCMD_ARG_TGT_ARCH% == x86 (
  cl /nologo /EP /P /I. /I../include ../src/x86/sysv_intel.S /Fimsvc_x86.asm
)

if %VSCMD_ARG_TGT_ARCH% == x64 (
  cl /nologo /EP /P /I. /I../include ../src/x86/win64_intel.S /Fimsvc_x64.asm
)

if %VSCMD_ARG_TGT_ARCH% == arm (
  cl /nologo /EP /P /I. /I../include ../src/arm/sysv_msvc_arm32.S /Fimsvc_arm.asm
)

if %VSCMD_ARG_TGT_ARCH% == arm64 (
  cl /nologo /EP /P /I. /I../include ../src/aarch64/win64_armasm.S /Fimsvc_arm64.asm
)
