#include <stdio.h>

void secret() {
    puts("you got me!");
}

void vuln() {
    char buf[32];
    gets(buf);
}

int main() {
    vuln();
    return 0;
}