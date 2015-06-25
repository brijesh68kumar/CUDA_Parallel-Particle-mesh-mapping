//#include<conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <sys/time.h>
#include "time.h"

using namespace std;

//struct timeval tv;


__global__ void parMap(float *pD, float *netD, int grid)
{
        unsigned int rID= blockDim.x*blockIdx.x + threadIdx.x;
        int left, right, top, bottom;
        float x,y, fL,fR,fB,fT;


        //x=pD[1];
        x = pD[rID*2];
        //x=102.358000;

        y = pD[rID*2+1];
                                //y=320.568000;
                                //printf("%d %f %f       ",rID,x,y);

        //printf("thread: %d x:%f, y:%f  \n", rID,x,y);

        left = (int)floorf(x);
        right = left + 1;

        bottom = (int)floorf(y);
        top = bottom +1;

        //printf("left:%d, right:%d,top:%d, bottom:%d   \n", left, right, top, bottom );

        if (left>= grid||right>= grid||top>= grid||bottom>= grid)
                {
                        left=0;
                        right=1;
                        top=1;
                        bottom = 0;
                        x=0.500000;
                        y=0.500000;
                }

                fL = x - left;
                fR = 1 - fL;

                fB = y - bottom;
                fT = 1 - fB;

        //      printf("fL:%f, fR:%f, fT:%f, fB:%f L:%d, R:%d, T:%d, B:%d   \n", fL, fR, fT,fB, left, right, top, bottom );

        //      printf("L:%d, R:%d, T:%d, B:%d   \n", left, right, top, bottom );


        //      printf("grid: left:%f, right:%f, top:%f, bottom:%f \n", netD[left], netD[right], netD[top], netD[bottom]);
                netD[grid*left + bottom]  = netD[grid*left + bottom] +(fT*fR);
                netD[grid*right + bottom] = netD[grid*right + bottom]+(fT*fL);
                netD[grid*left+ top]      = netD[grid*left + top]    +(fB*fR);
                netD[grid*right+ top]     = netD[grid*right + top]   +(fB*fL);

//              if(rID%50==1)
//                      printf("grid: left:%f, right:%f, top:%f, bottom:%f \n", netD[left], netD[right], netD[top], netD[bottom]);


}



// main function
int main(int argc, char *argv[])
{
        int grid = 1024, i, j, lp=1,max = grid, sizeGrid= grid*grid;
        unsigned int par = 160000, loop=2000, sizePar = 2*par;

        cudaEvent_t s_i, e_i, s_mc_h2d, e_mc_h2d, s_mc_d2h, e_mc_d2h, s_pl, e_pl;
        float t_i=0.0, t_mc_h2d=0.0, t_mc_d2h=0.0, t_pl=0.0, ti=0.0, tmc_h2d=0.0, tpl=0.0;

        cudaEventCreate(&s_i);          cudaEventCreate(&s_mc_h2d);
        cudaEventCreate(&e_i);          cudaEventCreate(&e_mc_h2d);

        cudaEventCreate(&s_mc_d2h);             cudaEventCreate(&s_pl);
        cudaEventCreate(&e_mc_d2h);             cudaEventCreate(&e_pl);




        /*
                float* netH;
                float* pH;
                float* netD;
                float*  pD;
                */

        float *netH, *pH, *netD,  *pD;

        cudaEventRecord(s_i,0);

        netH =        (float*)malloc(sizeof(float)*sizeGrid);
        pH   =        (float*)malloc(sizeof(float)*sizePar);

        //intialising particles.


        cudaEventRecord( s_i,0 );

        for(i=0;i< grid;i++)
                for(j=0;j< grid;j++)
                        netH[grid*i+j]=0.0;
        for( i = 0; i < sizePar; i++)
                pH[i]= ((float)rand()/(float)(RAND_MAX) * (float)(max-1));


        cudaMalloc( (void **)&netD, sizeof(float)*sizeGrid);
        cudaMemcpy(netD, netH, sizeGrid*(sizeof(float)),  cudaMemcpyHostToDevice);

                cudaEventRecord( e_i,0 );
                cudaEventSynchronize( e_i );
                cudaEventElapsedTime( &ti, s_i, e_i);


	for(lp=1;lp<loop;lp++)
	{
        //	for( i = 0; i < sizePar; i++)
        //	       pH[i]= ((float)rand()/(float)(RAND_MAX) * (float)(max-1));

//        printf("particle initialised \n ");
//        printf("Grid initialised \n ");
/*       	cudaEventRecord( e_i,0 );
        	cudaEventSynchronize( e_i );
        	cudaEventElapsedTime( &ti, s_i, e_i);
*/
        // Allocating GPU memory
        	cudaEventRecord(s_mc_h2d,0);
//        cudaMalloc( (void **)&netD, sizeof(float)*sizeGrid);
        	cudaMalloc( (void **)&pD, sizeof(float)*sizePar);
//        printf("Cuda memory allocated \n ");
        //transfering data to gpu
        	cudaMemcpy( pD,   pH,   sizePar*(sizeof(float)),  cudaMemcpyHostToDevice);
//        cudaMemcpy(netD, netH, sizeGrid*(sizeof(float)),  cudaMemcpyHostToDevice);

        	cudaEventRecord( e_mc_h2d,0 );
        	cudaEventSynchronize( e_mc_h2d );
        	cudaEventElapsedTime( &tmc_h2d, s_mc_h2d, e_mc_h2d);
//        printf("Data cpy to gpu \n \n ");
        //initialising the thread in groups
        	cudaEventRecord( s_pl,0 );
        	dim3 dimBlock(192);
        	dim3 dimGrid((par/192));
//        printf("Thread launched \n \n ");
        //@@ Launch the GPU Kernel here
	        parMap<<<dimGrid, dimBlock>>>(pD, netD, grid);
//        printf("Data back to CPU \n \n ");
	        cudaEventRecord( e_pl,0 );
	        cudaEventSynchronize( e_pl );
	        cudaEventElapsedTime( &tpl, s_pl, e_pl);

		t_i+=ti;
		t_mc_h2d+=tmc_h2d;
		t_pl+=tpl;	
	}


        // Copy the results in GPU memory back to the CPU
        cudaEventRecord( s_mc_d2h,0 );

        cudaMemcpy(netH, netD, sizeof(float)*sizeGrid, cudaMemcpyDeviceToHost);

        cudaEventRecord( e_mc_d2h,0 );
        cudaEventSynchronize( e_mc_d2h );
        cudaEventElapsedTime( &t_mc_d2h, s_mc_d2h, e_mc_d2h);



        FILE *f = fopen("file.txt", "w");
	par*=loop;
        if (f == NULL)
        {
            printf("Error opening file!\n");
            exit(1);
        }


        float avg= par/(max*max);



        for ( i = 0; i < sizeGrid; ++i)
        {
                        //cout<<netH[i]<<" ";
        fprintf (f,"%f ",((netH[i])/avg))  ;// /temp1));
            if (i%grid==(grid-1))
                {
                        //printf("\n");
                        fprintf (f," \n" );
                }
        }

        fclose(f);

//        cout<<"Grid size: "<<grid<<"x"<<grid<<"  particles:"<<par <<"\n";
//        cout<<"Initialisation time: "<<t_i<<"\n";
//        cout<<"Memory copy H 2 d:   "<<t_mc_h2d<<"\n";
//        cout<<"Memory copy D 2 H:   "<<t_mc_d2h<<"\n";
//        cout<<"Processing time:     "<<t_pl<<"\n";
//        cout<<"Total time:          "<<( t_mc_h2d + t_mc_d2h + t_pl )<<"\n";



       printf("\n\nGrid size: \t\t%d \nparticle:\t %d\n", grid,par);
       printf("\nInitialisation time:\t%f \n", t_i);
       printf("\nMemory Copy H 2 D:\t%f \n", t_mc_h2d);
       printf("\nMemory Copy D 2 H:\t%f \n", t_mc_d2h);
       printf("\nProcessing time:\t%f \n\n", t_pl);




        //event destroy
        cudaEventDestroy(s_i);    cudaEventDestroy(s_mc_h2d);    cudaEventDestroy(s_mc_d2h);
        cudaEventDestroy(e_i);    cudaEventDestroy(e_mc_h2d);    cudaEventDestroy(e_mc_d2h);
        cudaEventDestroy(s_pl);
        cudaEventDestroy(e_pl);


        // Free the GPU memory
        cudaFree(netD);
        cudaFree(pD);

        free(netH);
        free(pH);

        return 0;
}

