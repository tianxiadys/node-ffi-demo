#include "node_ffi.h"
#include "windows.h"

int main()
{
    const auto a = new node::ffi::FFIDefinition("L");
    const auto b = new node::ffi::FFICallback("L");
    delete a;
    delete b;
}
