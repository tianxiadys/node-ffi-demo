#include <dynload.h>
#include <dyncall.h>
#include <dyncall_callback.h>

int main()
{
    auto a = dlLoadLibrary("user32.dll");
    if (a)
    {
        auto b = dlFindSymbol(a, "MessageBoxW");
        if (b)
        {
        }
        dlFreeLibrary(a);
    }
    return 0;
}
