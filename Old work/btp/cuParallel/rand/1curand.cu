#include <stdio.h>
#include <curand.h>
#include <curand_kernel.h>

#define SCALE 1023
#define DSIZE 5000
#define nTPB 256

#define cudaCheckErrors(msg) \
    do { \
        cudaError_t __err = cudaGetLastError(); \
        if (__err != cudaSuccess) { \
            fprintf(stderr, "Fatal error: %s (%s at %s:%d)\n", \
                msg, cudaGetErrorString(__err), \
                __FILE__, __LINE__); \
            fprintf(stderr, "*** FAILED - ABORTING\n"); \
            exit(1); \
        } \
    } while (0)

__device__ float getnextrand(curandState *state){

  return (float)(curand_uniform(state));
}

__device__ int getnextrandscaled(curandState *state, int scale){

  return (int) scale * getnextrand(state);
}


__global__ void initCurand(curandState *state, unsigned long seed){
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    curand_init(seed, 0, 0, &state[idx]);
}

__global__ void testrand(curandState *state, float *a1, float *a2){
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

//    a1[idx] = getnextrandscaled(&state[idx], SCALE);
//    a2[idx] = getnextrandscaled(&state[idx], SCALE);
    a1[idx] = getnextrand(&state[idx]);
    a2[idx] = getnextrand(&state[idx]);

}

int main() {

    float *h_a1, *h_a2, *d_a1, *d_a2;
    curandState *devState;

    h_a1 = (float *)malloc(DSIZE*sizeof(float));
    if (h_a1 == 0) {printf("malloc fail\n"); return 1;}
    h_a2 = (float *)malloc(DSIZE*sizeof(float));
    if (h_a2 == 0) {printf("malloc fail\n"); return 1;}
    cudaMalloc((void**)&d_a1, DSIZE * sizeof(float));
    cudaMalloc((void**)&d_a2, DSIZE * sizeof(float));
    cudaMalloc((void**)&devState, DSIZE * sizeof(curandState));
    cudaCheckErrors("cudamalloc");



     initCurand<<<(DSIZE+nTPB-1)/nTPB,nTPB>>>(devState, 1);
     cudaDeviceSynchronize();
     cudaCheckErrors("kernels1");
     testrand<<<(DSIZE+nTPB-1)/nTPB,nTPB>>>(devState, d_a1, d_a2);
     cudaDeviceSynchronize();
     cudaCheckErrors("kernels2");
     cudaMemcpy(h_a1, d_a1, DSIZE*sizeof(float), cudaMemcpyDeviceToHost);
     cudaMemcpy(h_a2, d_a2, DSIZE*sizeof(float), cudaMemcpyDeviceToHost);
     cudaCheckErrors("cudamemcpy");
     printf("1st returned random value is %f\n", h_a1[0]);
     printf("2nd returned random value is %f\n", h_a2[0]);

     for (int i=1; i< DSIZE; i++){
       if (h_a1[i] != h_a1[0]) {
         printf("mismatch on 1st value at %d, val = %f\n", i, h_a1[i]);
         return 1;
         }
       if (h_a2[i] != h_a2[0]) {
         printf("mismatch on 2nd value at %d, val = %f\n", i, h_a2[i]);
         return 1;
         }
       }
     printf("thread values match!\n");

return 0;
}


