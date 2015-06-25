#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>
 
int main()
{
    int r = 100, c = 2,out=100, i, j, count,max=1024, loop, left, right, top, bottom;
    float net[1024][1024], x, y, fL, fR, fB, fT, time, totalTime;

	cudaEvent_t start1, stop1;
        cudaEventCreate(&start1);
        cudaEventCreate(&stop1);
  


    

 
    float **arr = (float **)malloc(r * sizeof(float *));
    for (i=0; i<r; i++)
         arr[i] = (float *)malloc(c * sizeof(float));
 

    for (loop=0;loop<out;loop++)
        {
    // Note that arr[i][j] is same as *(*(arr+i)+j)
        for (i = 0; i <  r; i++)
          for (j = 0; j < c; j++)
             arr[i][j] =((float)rand()/(float)(RAND_MAX) * (float)max) ;  // OR *(*(arr+i)+j) = ++count
 
	cudaEventRecord (start1,0);

        for (i = 0; i <  r-1 ; i++)
	    {
//          for (j = 0; j < c; j++)
//             printf("%f ", arr[i][j]);

                x = arr[i][0];
                y = arr[i][1];

                left = (int)floor(x);
                right = left + 1;

                bottom = (int)floor(y);
                top = bottom +1;

                fL = x - left;
                fR = 1 - fL;

                fB = y - bottom;
                fT = 1 - fB;

		if (left>=1024||right>=1024||bottom>=1024||top>=1024)		break;

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
                cudaEventDestroy(start1);
                cudaEventDestroy(stop1);


   /* Code for further processing and free the 
      dynamically allocated memory */

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

