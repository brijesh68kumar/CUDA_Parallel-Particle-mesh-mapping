#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>
#include "time.h"

int main(int argc, char *argv[])
{

        int max = 64, i,j,lp;
        int top,bottom,left,right;

        float net[64][64];
        float x,y, fL, fR, fB, fT;

        unsigned int par=160000, loop=2000;

        struct timespec start,stop;
        double t1=0,t2=0,result=0;

        //intialising particles.
    /*  for( i = 0; i < par; i++)
        {
                p[i][0]= ((float)rand()/(float)(RAND_MAX) * (float)max);
                p[i][1]= ((float)rand()/(float)(RAND_MAX) * (float)max);
        }*/

 //------------------calculate Starting time----------------------
        clock_gettime(CLOCK_REALTIME,&start);
        t1 = start.tv_sec + (start.tv_nsec/pow(10,9));

        for (i=0;i<max;i++)
                for (j=0; j<max;j++)
                        net[i][j]=0;

	for (lp=1;lp<loop;lp++){
        for ( i = 0; i < par; ++i)
        {
                x = ((float)rand()/(float)(RAND_MAX) * (float)max);
                y = ((float)rand()/(float)(RAND_MAX) * (float)max);

                left = (int)floor(x);
                right = left + 1;

                bottom = (int)floor(y);
                top = bottom +1;

        if (top>=max||bottom>=max||left>=max||right>=max)
            continue; 

                fL = x - left;
                fR = 1 - fL;

                fB = y - bottom;
                fT = 1 - fB;

                net[left][bottom]       =       net[left][bottom]       +( fT * fR ) ;
                net[right][bottom]      =       net[right][bottom]      +( fT * fL ) ;
                net[left][top]          =       net[left][top]          +( fB * fR ) ;
                net[right][top]         =       net[right][top]         +( fB * fL ) ;
        }
	}


 //---------------calculate End time-------------------------
        clock_gettime(CLOCK_REALTIME,&stop);
        t2 = stop.tv_sec + (stop.tv_nsec/pow(10,9));



        FILE *f = fopen("file1.txt", "w");
        if (f == NULL)
        {
        printf("Error opening file!\n");
        exit(1);
        }

                for ( i = 0; i < max; ++i)
                {
                        for ( j = 0; j < max; j++)
                        {
//                                printf ("%f ,",net[i][j] );
                                fprintf (f,"%f ,",net[i][j] );
                        }
//                        printf ("\n" );
                        fprintf (f,"\n" );
                }
        fclose(f);

        result = t2 - t1 ;

        printf("its done:\t%lf s\n", result);
        return 0;
}

