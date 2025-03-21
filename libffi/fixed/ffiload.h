/*
 * This file is written by Node.js,
 * and the original code of the libffi library does not include this file.
 */
#ifndef LIBFFI_FIXED_LOAD_H
#define LIBFFI_FIXED_LOAD_H

#ifdef __cplusplus
extern "C" {
#endif

void* ffi_load_library(const char* libPath);
void* ffi_find_symbol(void* pLib, const char* pSymbolName);
int ffi_free_library(void* pLib);

#ifdef __cplusplus
}
#endif

#endif
