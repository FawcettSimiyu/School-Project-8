// gcc file1.c -fno-stack-protector -m32 -g -z execstack -w -o file1.exe
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_BUFFER 64
#define MAX_ITEMS 100

// Structure to hold mixed data (words or numbers)
typedef struct {
    char *word;
    int number;
    int isNumber; // Flag: 1 for number, 0 for word
} DataItem;


DataItem* processFile(char *filename, int *itemCount);
char* extractResult(DataItem *items, int itemCount, int index, int type);
void freeItems(DataItem *items, int itemCount);

int main(int argc, char **argv) {
    char *filename = "data1.txt" ;
    int index = 0 ;
    int type = 0 ;

    // Parse command-line arguments
    if (argc > 1) {
        index = atoi(argv[1]); // Index to extract
    }
    if (argc > 2) {
        type = atoi(argv[2]);  // Type: 0 for word, 1 for number
    }

    int itemCount = 0;
    DataItem *items = processFile(filename, &itemCount);

    if (itemCount == 0) {
        printf("No data processed.\n");
        return 1;
    }

    char *result = extractResult(items, itemCount, index, type);
    if (result) {
        printf("Result: %s\n", result);
        free(result); 
    } else {
        printf("Invalid index or type.\n");
    }

    freeItems(items, itemCount); 
    return 0;
}

// Process file and store words/numbers in a dynamic array of type DataItem
DataItem* processFile(char *filename, int *itemCount) {
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        printf("Error opening file %s\n", filename);
        exit(1);
    }

    DataItem *items = malloc(MAX_ITEMS * sizeof(DataItem));
    char buffer[MAX_BUFFER];
    int count = 0;

    while (count < MAX_ITEMS && fscanf(fp, "%s", buffer) == 1) {
        items[count].word = malloc(MAX_BUFFER);
        int num;
        if (sscanf(buffer, "%d", &num) == 1) { // If it is a number
            items[count].number = num;
            items[count].isNumber = 1;
            sprintf(items[count].word, "%d", num); 
        } else { // If it's a word
            strcpy(items[count].word, buffer) ;
            items[count].isNumber = 0 ;
            items[count].number = 0 ;
        }
        count++;
    }

    fclose(fp);
    *itemCount = count;
    return items;
}

// Extract the requested item based on index and type
char* extractResult(DataItem *items, int itemCount, int index, int type) {
    int typeCount = 0;
    char i;
    for (i = 0; i < 128; i++) { 
        if (items[i].isNumber == type) {
            if (typeCount == index) {
                char *result = malloc(MAX_BUFFER);
                strcpy(result, items[i].word); 
                return result;
           }
            typeCount++;
        }
    }
    return NULL ;
}

void freeItems(DataItem *items, int itemCount) {
    for (int i = 0; i < itemCount; i++) {
        free(items[i].word);
    }
    free(items);
}

