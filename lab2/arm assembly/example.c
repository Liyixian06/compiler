#include <stdio.h>
int i = 2;
int f = 1;
int factorial(int i, int n, int f)
{
	while (i <= n)
  {
    f = f * i;
    i = i + 1;
  }
  return f;
}
int main(){
  int n;
  scanf("%d", &n);
  printf("%d\n", factorial(i, n, f));
  return 0;
}
