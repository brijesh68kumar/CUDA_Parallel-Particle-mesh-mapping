/* Algo to so the weight distribution of 5000 particle on a 
   grid of 64x64 */


//#include<conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>


//function to calculate the contribution on each coordinate.


// main function
int main(int argc, char *argv[])
{
	cudaEvent_t start_i, stop_i;
	float time_i;
	
	
	cudaEventCreate(&start_i);
	cudaEventCreate(&stop_i);
	

	int max = 64;
//	int min = 0;

	float net[64][64];
	int i;
	int j;

	float p[20500][2]; //rows is number of particles. (first coloumn , second coloumn) is (x,y) 

        printf("Till initialisation\n");



	//intialising particles.
	for( i = 0; i < 20500; i++)
	{
		p[i][0]= ((float)rand()/(float)(RAND_MAX) * (float)max);
		p[i][1]= ((float)rand()/(float)(RAND_MAX) * (float)max);
	}

        printf("elements are decleared\n");

	cudaEventRecord(start_i,0);
	
	for ( i = 0; i < 20450; ++i)
	{
		float x = p[i][0];
		float y = p[i][1];

		int left = (int)floor(x);
		int right = left + 1;

		int bottom = (int)floor(y);
		int top = bottom +1;

		float fL = x - left;
		float fR = 1 - fL;

		float fB = y - bottom;
		float fT = 1 - fB;

		net[left][bottom] 	= 	net[left][bottom]	+( fT * fR ) ;
		net[right][bottom] 	= 	net[right][bottom]	+( fT * fL ) ;
		net[left][top]		=	net[left][top]		+( fB * fR ) ;
		net[right][top]		=	net[right][top]		+( fB * fL ) ;
	}
	cudaEventRecord(stop_i,0);
	cudaEventElapsedTime( &time_i, start_i,stop_i );
	printf("\n Total processing time: %f \n", time_i );


	FILE *f = fopen("file.txt", "w");
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
	cudaEventDestroy(start_i);
	cudaEventDestroy(stop_i);



	return 0;
}

