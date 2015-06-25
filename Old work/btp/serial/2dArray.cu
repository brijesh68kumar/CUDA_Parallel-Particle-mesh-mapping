#include <stdio.h>
#include <stdlib.h>

int main() {
  float **p;
  int m, n, i, j;

  printf("Enter number of rows and columns: ");
  scanf("%d%d", &m, &n);

  /* Allocate memory */
  p = (float *) malloc(sizeof(float *) * m); /* Row pointers */
  for(i = 0; i < m; i++) {
    p[i] = (float) malloc(sizeof(float) * n); /* Rows */
  }

  /* Assign values to array elements and print them */
  for(i = 0; i < m; i++) {
    for(j = 0; j < n; j++) {
      p[i][j] = (i * 10) + (j + 1);
      printf("%6.2f ", p[i][j]);
    }
    printf("\n");
  }

  /* Deallocate memory */
  for(i = 0; i < m; i++) {
    free(p[i]); /* Rows */
  }
  free(p); /* Row pointers */
}
