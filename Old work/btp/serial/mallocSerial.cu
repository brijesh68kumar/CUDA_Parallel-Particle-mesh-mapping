/* Algo to so the weight distribution of 5000 particle on a
   grid of 64x64 */


//#include<conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>



// main function
int main(int argc, char *argv[])
{

//        int numElement = 2;
        int numArray   = 1000;
//        int loop       = 1000;

        int i;
        int j;
        int max = 1024;
        float net[1024][1024];

        float **ptr;
        ptr = (float **)malloc(numArray*sizeof(float));


        for(i=0; i < numArray; i++)
        {
         *(*(ptr+i)+0) = ((float)rand()/(float)(RAND_MAX) * (float)max);
         *(*(ptr+i)+1) = ((float)rand()/(float)(RAND_MAX) * (float)max);
        }

        for(i=0; i < numArray; i++)
        {
                float x = *(*(ptr+i)+0);
                float y = *(*(ptr+i)+1);

                int left = (int)floor(x);
                int right = left + 1;

                int bottom = (int)floor(y);
                int top = bottom +1;

                float fL = x - left;
                float fR = 1 - fL;

                float fB = y - bottom;
                float fT = 1 - fB;

                net[left][bottom]  = net[left][bottom]  +( fT*fR );
                net[right][bottom] = net[right][bottom] +( fT*fL );
                net[left][top]     = net[left][top]     +( fB*fR );
                net[right][top]    = net[right][top]    +( fB*fL );
        }








/*
       int max = 1024;
        //int min = 0;

        float net[1024][1024];
        int i;
        int j;
        int size = 10000;

        double p[size][2]; //rows is number of particles. (first coloumn , second coloumn) is (x,y)
        float totalTime;

        //      cudaEvent_t start1, stop1;
        //        cudaEventCreate(&start1);
        //        cudaEventCreate(&stop1);
        //        float time;

        for(j=0; j < size;j++)
        {

                cudaEvent_t start1, stop1;
                cudaEventCreate(&start1);
                cudaEventCreate(&stop1);
                float time;




                //intialising particles.
                for( i = 0; i < size; i++)
                {
                   p[i][0]= ((float)rand()/(float)(RAND_MAX) * (float)max);
                   p[i][1]= ((float)rand()/(float)(RAND_MAX) * (float)max);
                }

                printf("\nvalue of P are %f, %f \n", p[size-1][0], p[size-1][1] );

                cudaEventRecord (start1,0);

                for ( i = 0; i < size; ++i)
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

                        net[left][bottom]  = net[left][bottom]  +( fT*fR );
                        net[right][bottom] = net[right][bottom] +( fT*fL );
                        net[left][top]     = net[left][top]     +( fB*fR );
                        net[right][top]    = net[right][top]    +( fB*fL );
                }
                cudaEventRecord (stop1,0);
                cudaEventSynchronize ( stop1 );
                cudaEventElapsedTime ( &time, start1, stop1 );
                printf("\n seconds: %f \n", time);

                cudaEventDestroy(start1);
                cudaEventDestroy(stop1);


                totalTime = totalTime+time;
        }

        printf("\nSeconds: %f \n", totalTime);
*/

        FILE *f = fopen("file.txt", "w");
        if (f == NULL)
        {
        printf("Error opening file!\n");
        exit(1);
        }

                for ( i = 0; i < 1023; ++i)
                {
                        for ( j = 0; j < 1023; j++)
                        {

                                fprintf (f,"%f ,",net[i][j] );
                        }

                        fprintf (f,"\n" );
                }

        fclose(f);


        return 0;
}



