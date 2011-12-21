// @author: youlizhao.nju@gmail.com
// @date: Nov. 28, 2011
// @function: Given samples from USRP, output data statistics: START, END, AVG_ENERGY using double sliding window approach
// @examples: ./test rx_data3.dat

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <test.h>

float CalculateEnergy(float rxdata[], int startPos, int BLOCK_LEN);

int main(int argc, char ** argv) {
  printf("Hello World!\n");

  char in[30];
  strcpy(in, argv[1]);
  fp1 = fopen(in, "rb");
  if( (fp1 == NULL) ) {
    printf("File Open Error\n");
    exit(1);
  }

  // start reading packet samples
  float buffer[BLOCK_SIZE*2];
  float winEnergy[WINDOW_SIZE];
  int indexBuffer = 0;	// index for buffer
  int indexWindow = 0;  // index for energy window
  int rSamples = 0;	// number of reading samples

  // intial reading
  rSamples = fread(buffer, sizeof(float), BLOCK_SIZE*2, fp1);
  if (rSamples != BLOCK_SIZE*2) {
    printf("Initial Reading Error\n");
    exit(1);
  }

  float readBuffer[2];

  // calculate energy for initial block
  winEnergy[indexWindow] = CalculateEnergy(buffer, BLOCK_SIZE*2, indexBuffer, BLOCK_SIZE);
  indexWindow = (indexWindow + 1) % WINDOW_SIZE;

  while( !feof(fp1) ) {
    // check peak for current position
    
    rSamples += fread(readBuffer, sizeof(float), 2, fp1);
    int iPos = indexBuffer*2, qPos = indexBuffer*2+1;
    buffer[iPos] = readBuffer[1];
    buffer[qPos] = readBuffer[2];
    indexBuffer = (indexBuffer + 1) % BLOCK_SIZE;
    //////////////////////////////////////////////
    //  stop here and wait for further signal
    //  focus on STS self-correlation results
    //////////////////////////////////////////////
    
  }

}

// @function: calculate BLOCK energy using double sliding window approach
// @input: 
//	   rxdata[]: array for input data. size(rxdata) = BLOCK_LEN*2
//	   startPos: start posistion of rxdata since we use cyclic to store rxdata
//	   BLOCK_LEN: length of BLOCK
// @output: 
//	   energy ratio of double window	   
float CalculateEnergy(float rxdata[], int startPos, int BLOCK_LEN) {
  float E1 = 0, E2 = 0;
  for(int i=0; i < BLOCK_LEN; i++) {
    int iPos1 = (startPos+2*i)%(BLOCK_LEN*2);
    int qPos1 = (startPos+2*i+1)%(BLOCK_LEN*2);
    float value1 = rxdata[iPos1]*rxdata[iPos1] + rxdata[qPos1]*rxdata[qPos1];
    E1 += sqrt(value1);

    int iPos2 = (startPos+BLOCK_LEN+2*i)%(BLOCK_LEN*2);
    int qPos2 = (startPos+BLOCK_LEN+2*i+1)%(BLOCK_LEN*2);
    float value2 = rxdata[iPos2]*rxdata[iPos2] + rxdata[qPos2]*rxdata[qPos2];
    E2 += sqrt(value2);
  }
  return E2/E1;
}
