#include "node_ffi.h"
#include "windows.h"

BOOL enumProc(HWND hWnd, LPARAM lParam)
{
    wprintf(L"wnd:%p\n", hWnd);
    return 1;
}

int main()
{
    node::ffi::FFIFunction a("ipL", EnumWindows);
    node::ffi::FFICallback b("ipL");
    void* ptr = b.address;
    a.setParam(0, &ptr);
    ffi_raw ret;
    a.doInvoke(&ret);
}
