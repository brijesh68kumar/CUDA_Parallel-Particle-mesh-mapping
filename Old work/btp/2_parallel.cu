#include<cuda.h>
#include<stdio.h>
#include<math.h>

//Matrix multiplication kernel - thread specification
__global__ void MatrixMulKernel(float *Md, float *net, int Width, int numPar) {
	//2D Thread ID
	int tx = threadIdx.x;

	if (tx % 2 == 0)
	{


		float x = Md[tx];
		float y = Md[tx + 1];

//		printf("hello");

		int left = (int)floor(x);
		int right = left + 1;

		int bottom = (int)floor(y);
		int top = bottom + 1;

		float fL = x - left;
		float fR = 1 - fL;

		float fB = y - bottom;
		float fT = 1 - fB;

		net[left*Width + bottom] = net[left*Width + bottom] + (fT * fR);
		net[right*Width + bottom] = net[right*Width + bottom] + (fT * fL);
		net[left*Width + top] = net[left*Width + top] + (fB * fR);
		net[right*Width + top] = net[right*Width + top] + (fB * fL);
	}
	
}





void MatrixMultiplication(float *M, float *P, int Width, int numPar) {
	int size = Width*Width*sizeof(float);
	float *Md;
	float *Pd;
	int sizep = 2 * numPar*sizeof(float);

	//Transfer M and N to device memory
	cudaMalloc((void**)&Md, sizep);
	cudaMemcpy(Md, M, sizep, cudaMemcpyHostToDevice);
	printf("before allocation");
	//Allocate P on the device
	cudaMalloc((void**)&Pd, size);

	//Setup the execution configuration
	dim3 dimBlock(Width, Width);
	dim3 dimGrid(1, 1);

	//Launch the device computation threads!
	MatrixMulKernel << <dimGrid, dimBlock >> >(Md, Pd, Width, numPar);

	printf("after kernal");

	//Transfer P from device to host
	cudaMemcpy(P, Pd, size, cudaMemcpyDeviceToHost);

	//Free device matrices
	cudaFree(Md);
	cudaFree(Pd);
}



int main(void) {
	void MatrixMultiplication(float *, float *, int, int);
	const int Width = 64;
	const int nP = 50000;
	float M[nP * 2];      //, N[Width*Width], 
	float P[Width*Width];
	for (int i = 0; i < (nP * 2); i++) {
		M[i] = ((float)rand() / (float)(RAND_MAX)* (float)Width);;
	}

	MatrixMultiplication(M, P, Width, nP);
	for (int i = 0; i < (Width*Width); i++) {
//		printf("%f \n", P[i]);
	}



	FILE *f = fopen("Par.txt", "w");
	if (f == NULL)
	{
		printf("Error opening file!\n");
		exit(1);
	}

	/*
	int i;
	for (i = 0; i < Width*Width; ++i)
	{

		fprintf(f, "%f ,", P[i]);
		if ((i %Width) == 0)
		{
			fprintf(f, "\n");
		}
	}

	fclose(f);
	*/

	int i;
	for (i = 0; i < Width; ++i)
	{

		printf("%f ,", P[i]);
		if ((i %Width) == 0)
		{
			printf( "\n");
		}
	}




	int quit;
	scanf("%d", &quit);
	return 0;
}


