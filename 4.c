#include <stdio.h>
#include <string.h>

int main()
{
    char buff[15];
    int pass = 0;

    printf("\nEnter the password:\n");

    fgets(buff, sizeof(buff), stdin);
    buff[strcspn(buff, "\n")] = '\0';

    if (strcmp(buff, "thegeekstuff"))
    {
        printf("\nWrong Password\n");
    }
    else
    {
        printf("\nCorrect Password\n");
        pass = 1;
    }

    if (pass)
    {
        printf("\nRoot privileges given to the user\n");
    }
    else
    {
        printf("\nNo root privileges are granted.\n");
    }

    return 0;
}
