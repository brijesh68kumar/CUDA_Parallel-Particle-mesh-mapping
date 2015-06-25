#include <stdio.h>
__global__ void foo()
{
   printf("i am in kernal");
}

int main()
{
  foo<<<1,1>>>();
  printf("CUDA error: %s\n", cudaGetErrorString(cudaGetLastError()));
  return 0;
}
