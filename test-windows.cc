#include <ffi.h>
#include <ffiload.h>
#include <windows.h>
#include <stdio.h>

int test(int a, wchar_t* b, wchar_t* c, int d)
{
    wchar_t* x = (wchar_t*)((uintptr_t)(b) & 0xFFFFFFFF);
    return 0;
}

int main()
{
    auto user32 = ffi_load_library("user32");
    auto func1 = ffi_find_symbol(user32, "MessageBoxW");

    // 定义 FFI 类型
    ffi_cif cif; // 调用接口

    // 参数类型
    ffi_type* arg_types[4]; // 参数类型
    arg_types[0] = &ffi_type_pointer; // HWND (void*)
    arg_types[1] = &ffi_type_pointer; // LPCWSTR (wchar_t*)
    arg_types[2] = &ffi_type_pointer; // LPCWSTR (wchar_t*)
    arg_types[3] = &ffi_type_uint32; // UINT

    // 初始化 FFI 调用接口
    if (ffi_prep_cif(&cif, FFI_WIN64, 4, &ffi_type_sint32, arg_types) != FFI_OK)
    {
        printf("Failed to prepare FFI interface\n");
        return 1;
    }

    // 准备参数值
    HWND hwnd = NULL;
    const wchar_t* message = L"Hello, World!";
    const wchar_t* caption = L"libffi Example";
    UINT type = MB_OK;

    void* arg_values[4]; // 参数值
    arg_values[0] = &hwnd; // 窗口句柄
    arg_values[1] = &message; // 消息内容
    arg_values[2] = &caption; // 标题
    arg_values[3] = &type; // 消息框类型

    // 调用 MessageBoxW
    int result;
    ffi_call(&cif, FFI_FN(func1), &result, arg_values);


    return 0;
}
