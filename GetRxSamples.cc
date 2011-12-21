// @author: youlizhao.nju@gmail.com
// @date: Nov. 16, 2011
// @function: Given samples from USRP, cut samples from START to END
// @examples: ./GetRxSamples rx_data3.dat IQ.dat 1 1000000

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char ** argv) {
  printf("Hello World!\n");

  char in[30], out[30];
  strcpy(in, argv[1]);
  strcpy(out, argv[2]);

  int start = atoi(argv[3]);
  int end = atoi(argv[4]);

//  printf("argc = %d\n", argc);
//  for (int i = 0; i<argc; i++)
//    printf("argv[%d] = %s\n", i, argv[i]);

  int count, total = 0;
  float buffer[2];
  FILE *fp1, *fp2;
 
  fp1 = fopen(in, "rb");
  fp2 = fopen(out, "wb");

  if( (fp1 == NULL) or (fp2 == NULL) ) {
    printf("File Open Error\n");
    exit(1);
  }

  while( !feof(fp1) ) {
    count = fread(buffer, sizeof(float), 2, fp1);
    if( ferror(fp1) ) {
      perror("Read Error");
      break;
    }
    total += count;
    
//    fprintf(fp2, "%f \t %f\n", buffer[0], buffer[1]);
    if( (total>=(start)*2) && (total<=(end)*2) ) {
      fwrite(buffer, 2, sizeof(float), fp2);
    }
  }

  printf("Number of bytes read = %d\n", total);
  fclose(fp1);
  fclose(fp2);
}
