#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<dlfcn.h>

int main()
{
    void *sofile = NULL;
    char pre[20] = "";
    char op[20];
    int a,b;
    while(1)
    {
        if(scanf("%s %d %d", op,&a,&b) != 3)break;
        if(strcmp(op,pre) != 0)
        {
            if(sofile != NULL)
            {
                dlclose(sofile);
                sofile = NULL;
            }

            strcpy(pre, op);
            char lib[30] = "./lib";
            strcat(lib, op);
            strcat(lib, ".so");
            sofile = dlopen(lib, RTLD_LAZY);
        }
        int (*func)(int, int) = (int (*)(int, int))dlsym(sofile, op);
        int result = func(a, b);
        printf("%d\n", result);
    }

    if(sofile != NULL)
    {
        dlclose(sofile);
    }
    return 0;
}