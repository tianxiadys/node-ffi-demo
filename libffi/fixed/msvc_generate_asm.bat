@echo off

if %Platform% == x86 (
  cl /nologo /EP /P /I. /I../include ../src/x86/sysv_intel.S /Fiwin32_x86.asm
)

if %Platform% == x64 (
  cl /nologo /EP /P /I. /I../include ../src/x86/win64_intel.S /Fiwin32_x64.asm
)
