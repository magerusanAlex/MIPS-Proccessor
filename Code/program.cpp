#include <stdio.h> 

int main() 
{ 
    int a = 2;
    int b = 90;
    int x[] = {0, 1, 2, 3, 256, 14, 16};
    int n = 7;
    
    int sum = 0;
    int i = -1;

    while (i < n - 1) 
    {
        i++; 

        int val = x[i]; 
        
        if (val < a) 
            continue;

        if (val > b) 
            continue;

        if (val <= 0) 
            continue;

        int temp = val - 1;      
        int test = val & temp;   

        if (test != 0) 
            continue;

        sum = sum + val;
    }

    printf("Suma este: %d\n", sum);

    return 0; 
}