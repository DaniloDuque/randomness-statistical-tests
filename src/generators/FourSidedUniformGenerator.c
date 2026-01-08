#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void generate_samples(int num_samples, const char* output_file) {
    FILE* file = fopen(output_file, "w");
    if (file == NULL) {
        fprintf(stderr, "Error opening file: %s\n", output_file);
        exit(1);
    }
    
    srand(time(NULL));
    
    fprintf(file, "%d\n", num_samples);
    fprintf(file, "1 4\n");
    for (int i = 0; i < num_samples; i++) {
        int value = (rand() % 4) + 1;  // {1,2,3,4}
        fprintf(file, "%d\n", value);
    }
    
    fclose(file);
    printf("Generated %d samples in %s\n", num_samples, output_file);
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Usage: %s <num_samples> <output_file>\n", argv[0]);
        return 1;
    }
    
    int num_samples = atoi(argv[1]);
    const char* output_file = argv[2];
    
    generate_samples(num_samples, output_file);
    
    return 0;
}