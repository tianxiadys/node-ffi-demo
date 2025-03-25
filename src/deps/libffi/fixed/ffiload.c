/*
 * This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#include "ffiload.h"

#ifdef _WIN32
#include <windows.h>

void* ffi_load_library(const char* libPath)
{
    wchar_t wPath[MAX_PATH];
    if (libPath == NULL)
    {
        return GetModuleHandleW(NULL);
    }
    if (MultiByteToWideChar(CP_UTF8, 0, libPath, -1, wPath, MAX_PATH))
    {
        return LoadLibraryW(wPath);
    }
    return NULL;
}

void* ffi_find_symbol(void* pLib, const char* pSymbolName)
{
    return (void*)GetProcAddress((HINSTANCE)pLib, pSymbolName);
}

int ffi_free_library(void* pLib)
{
    return FreeLibrary((HINSTANCE)pLib);
}
#else
#include <dlfcn.h>

void* ffi_load_library(const char* libPath)
{
    return dlopen(libPath, RTLD_GLOBAL | RTLD_NOW);
}

void* ffi_find_symbol(void* pLib, const char* pSymbolName)
{
    return dlsym(pLib, pSymbolName);
}

int ffi_free_library(void* pLib)
{
    return dlclose(pLib);
}
#endif
