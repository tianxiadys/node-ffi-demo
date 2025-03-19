#include <ffi.h>
#include <ffiload.h>

int main()
{
    auto user32 = ffi_load_library("user32");
    auto func1 = ffi_find_symbol(user32, "MessageBoxW");
    return 0;
}
