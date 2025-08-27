// gcc file2.c -fno-stack-protector -m32 -g -z execstack -w -o file2.exe
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void do_command(char *cmd) {
  system(cmd);
}

int display(char *input, int filesize);
int readFile(char *argv);

int main (int argc, char **argv)
{
  int select=1;
  if (argc>1)
    readFile(argv[1]);
  else 
    printf("Please enter a filename!\n");
}

int readFile(char *argv)
{
  FILE *inFile;
  char filename[24];
  char c;
  int x;
  int filesize=0;
  int ChunkID;
  int ChunkSize;
  char Format[8];
  int bitsPerSample;
  char *file;
  char ID[8],tmp;

  strncpy(filename,argv, 24);

  if ((inFile=fopen(filename,"r"))==NULL) { 
    printf("Error opening file\n"); 
    exit(0); 
  }

  while((c=fgetc(inFile))!=EOF)
    if (c!='\n')
      filesize++;

  printf("File size = %d\n",filesize);

  file=malloc(filesize*sizeof(char));

  rewind(inFile);

  fscanf(inFile,"%d",&ChunkID);
  fscanf(inFile,"%d",&ChunkSize);
  fscanf(inFile,"%s",Format);
  fscanf(inFile,"%d",&bitsPerSample);
  fscanf(inFile,"%c",&tmp);

  for (x=0;x<filesize-10;x++)
    fscanf(inFile,"%c",&file[x]);

  fscanf(inFile,"%s",ID); 
  fclose(inFile);

  printf("Chunk ID = %d\n",ChunkID);
  printf("Chunk Size = %d\n",ChunkSize);
  printf("Format = %s\n",Format);
  printf("Bits per sample = %d\n",bitsPerSample);
  printf("ID = %s\n",ID);

  display(file,filesize);

}

int display(char *input, int filesize)
{
  char *output;
  output=malloc(filesize*sizeof(char));
  strcpy(output,input); 
  printf(output); 
}

