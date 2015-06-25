#include<iostram>
#include<cuda.h>
#include<stdio.h>
#include<math.h>

#define fram 64
#define par 50000

__global__ int parMesh(float d_p[par][2] , int d_net[fram][fram] )
{
	int i = blockIdx.y*blockDim.y + threadIdx.y;
	int col = blockIdx.x*blockDim.x + threadIdx.x;

	if(i >= par|| col>=2)
	{
	    return 0 ;
	}
	else
	{

	    float x = d_p[i][0];
	    float y = d_p[i][1];
	    int left = (int)floor(x);
	    int right = left + 1;
	    int bottom = (int)floor(y);
	    int top = bottom +1;

	//if ((left<=32)&&(top<=32))
	
		/* code */
		
	    float fL = x - left;
	    float fR = 1 - fL;

	    float fB = y - bottom;
	    float fT = 1 - fB;

	    		d_net[left][bottom]	= net[left][bottom]+( fT * fR ) ;
			d_net[right][bottom]    = net[right][bottom]	+ ( fT * fL ) ;
			d_net[left][top]	= net[left][top]     + ( fB * fR ) ;
			d_net[right][top]	= net[right][top]	+ ( fB * fL ) ;
	}
}


int main()
{
       //Writing the results in a file 


	FILE *f = fopen("parallelCuda.txt", "w");
	if (f == NULL)
	{
    	    printf("Error opening file!\n");
    	    exit(1);
	}
	for ( i = 0; i < 64; ++i)
	{
	    for ( j = 0; j < 64; j++)
	    {
		fprintf (f,"%f ,",net[i][j] );
   	    }
	    fprintf (f,"\n" );
	}
	fclose(f);
}
