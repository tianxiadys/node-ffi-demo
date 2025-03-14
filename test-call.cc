#include <dynload.h>
#include <dyncall.h>
#include <dyncall_callback.h>
#include <cstdio>

DCsigchar EnumWindowsCB(DCCallback* pcb, DCArgs* args, DCValue* result, void* userdata)
{
    const auto a1 = dcbArgPointer(args);
    const auto a2 = dcbArgLongLong(args);
    printf_s("EnumWindows callback:%p, %lld\n", a1, a2);
    result->i = 1;
    return DC_SIGCHAR_INT;
}

int main()
{
    if (const auto a = dlLoadLibrary("user32.dll"))
    {
        if (const auto b1 = dlFindSymbol(a, "MessageBoxW"))
        {
            if (const auto b2 = dcNewCallVM(4096))
            {
                dcMode(b2, DC_CALL_C_X86_WIN32_STD);
                dcReset(b2);
                dcArgPointer(b2, nullptr);
                dcArgPointer(b2, (DCpointer)L"asd");
                dcArgPointer(b2, (DCpointer)L"qwe");
                dcArgInt(b2, 0);
                const auto b3 = dcCallInt(b2, b1);
                printf_s("MessageBoxW return:%d\n", b3);
                dcFree(b2);
            }
        }
        if (const auto c1 = dlFindSymbol(a, "EnumWindows"))
        {
            if (const auto c2 = dcNewCallVM(4096))
            {
                if (const auto c3 = dcbNewCallback2("pL)s", EnumWindowsCB, nullptr, nullptr))
                {
                    dcMode(c2, DC_CALL_C_X86_WIN32_STD);
                    dcReset(c2);
                    dcArgPointer(c2, c3);
                    dcArgLongLong(c2, 0);
                    const auto c4 = dcCallInt(c2, c1);
                    printf_s("EnumWindows return:%d\n", c4);
                    dcbFreeCallback(c3);
                }
                dcFree(c2);
            }
        }
        dlFreeLibrary(a);
    }
    return 0;
}
