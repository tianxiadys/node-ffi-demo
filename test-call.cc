#include <dynload.h>
#include <dyncall.h>
#include <dyncall_callback.h>

int main()
{
    if (const auto a = dlLoadLibrary("user32.dll"))
    {
        if (const auto b = dlFindSymbol(a, "MessageBoxW"))
        {
            if (const auto vm = dcNewCallVM(4096))
            {
                dcMode(vm, DC_CALL_C_X86_WIN32_STD);
                dcReset(vm);
                dcArgPointer(vm, nullptr);
                dcArgPointer(vm, (DCpointer)L"asd");
                dcArgPointer(vm, (DCpointer)L"qwe");
                dcArgInt(vm, 0);
                const auto c = dcCallInt(vm, b);
                dcFree(vm);
            }
        }
        dlFreeLibrary(a);
    }
    return 0;
}
