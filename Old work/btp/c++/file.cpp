#include<iostream>
using namespace std;

__global__ void initPosition()
{
cout<<"hello GPU\n";
}
int main(void)

{
initPosition<<<1,34>>>();
cout<<"I am in CPU\n";
return 0;
}

