/* Algo to so the weight distribution of 5000 particle on a
   grid of 64x64 */


//#include<conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>

using namespace std;

//__device__ float floorf       (float  x);


__global__ void parMap(float *p, float *net, int grid)
{
        int rID= blockDim.y*blockIdx.y + threadIdx.y;
        int x,y, left, right, top, bottom;
        float fL,fR,fB,fT;

                x = p[rID*2];

                y = p[rID*2+1];

//				printf("%d %f %f       ",rID,x,y);
//		cout<<x<<"  ";
                left = (int)floorf(x);
                right = left + 1;

                bottom = (int)floorf(y);
                top = bottom +1;

                if (left>= grid||right>= grid||top>= grid||bottom>= grid)
                {
                        left=0;
                        right=1;
                        top=1;
                        bottom = 0;
                }

                fL = x - left;
                fR = 1 - fL;

                fB = y - bottom;
                fT = 1 - fB;

                net[grid*left + bottom]  = net[grid*left + bottom] +(fT*fR);
                net[grid*right + bottom] = net[grid*right + bottom]+(fT*fL);
                net[grid*left+ top]      = net[grid*left + top]    +(fB*fR);
                net[grid*right+ top]     = net[grid*right + top]   +(fB*fL);

}



// main function
int main(int argc, char *argv[])
{
        int grid = 1024, i, max = grid, par=145623, sizeGrid= grid*grid, sizePar=par*2;

        	float* netH;
		float* pH;
		float* netD;
		float*  pD;

        netH =        (float*)malloc(sizeof(float)*sizeGrid);
        pH   =        (float*)malloc(sizeof(float)*par*2);
        //intialising particles.

      for( i = 0; i < sizePar; i++)
               pH[i]= ((float)rand()/(float)(RAND_MAX) * (float)max);

	printf("particle initialised \n "); 

	
        for(i=0;i<sizeGrid;i++)
                        netH[i]=0;
        printf("Grid initialised \n ");

        for(i=0;i<10;i++)
               //printf("%f, %f   ", netH[i], pH);
	cout<<netH[i]<<" "<<pH[i]<<" , ";


        // Allocating GPU memory
        cudaMalloc((void **)&netD, sizeof(float)*sizeGrid);
        cudaMalloc((void **)&pD, sizeof(float)*sizePar);

        printf("Cuda memory allocated \n ");

//    funcCheck(cudaMemcpy(netD, netH, grid*grid*sizeof(float), cudaMemcpyHostToDevice));
    cudaMemcpy(pD,   pH,   sizePar*(sizeof(float)),     cudaMemcpyHostToDevice);
    cudaMemcpy(netD, netH, sizeGrid*(sizeof(float)),  cudaMemcpyHostToDevice);

        printf("Data cpy to gpu \n \n ");

    // Initialize the grid and block dimensions
    dim3 dimBlock(32, 1);
    dim3 dimGrid(par/32,1);


    //@@ Launch the GPU Kernel here
    parMap<<<dimGrid, dimBlock>>>(netD, pD, grid);

    cudaError_t err1 = cudaPeekAtLastError();

        printf("Data back to CPU \n \n ");



    // Copy the results in GPU memory back to the CPU
    cudaMemcpy(netH, netD, sizeof(float)*sizeGrid, cudaMemcpyDeviceToHost);


//!! if(x<0) stop print i
//!! denominator -- nan

		/*
        FILE *f = fopen("file.txt", "w");
        if (f == NULL)
        {
            printf("Error opening file!\n");
            exit(1);
        }*/

        //  float temp1=par/(sizeGrid);

        for ( i = 0; i < 100; ++i)
        {
		
		//	printf("%f ",netH[i]);
		cout<< netH[i]<< "  ";
            //fprintf (f,"%f ",((netH[i])/temp1));
            if (i%grid==0)
		{
			printf("\n");
                	//fprintf (f," \n" );
		}
        }

        //fclose(f);

        // Free the GPU memory
        cudaFree(netD);
        cudaFree(pD);
		
//        free(netH);
//        free(pH);
		
        return 0;
}


