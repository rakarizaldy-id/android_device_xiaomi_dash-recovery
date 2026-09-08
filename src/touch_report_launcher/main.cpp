#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

using TouchMain = int (*)(int, char**);

int main(int argc, char** argv) {
    const char* path = "/odm/lib64/libtouchreport.so";
    void* handle = dlopen(path, RTLD_NOW | RTLD_GLOBAL);
    if (handle == nullptr) {
        fprintf(stderr, "dash_touch_report: dlopen(%s) failed: %s\n", path, dlerror());
        return 127;
    }

    dlerror();
    auto touch_main = reinterpret_cast<TouchMain>(dlsym(handle, "main"));
    const char* error = dlerror();
    if (error != nullptr || touch_main == nullptr) {
        fprintf(stderr, "dash_touch_report: dlsym(main) failed: %s\n", error ? error : "unknown");
        dlclose(handle);
        return 126;
    }

    return touch_main(argc, argv);
}
