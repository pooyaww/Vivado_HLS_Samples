#define DATA_LENGTH 1024
void vector_add(int a[DATA_LENGTH], int b[DATA_LENGTH], int c[DATA_LENGTH]) {
    int a_local[DATA_LENGTH];
    int b_local[DATA_LENGTH];
    memcpy(a_local, (const int*)a,DATA_LENGTH*sizeof(int));
    memcpy(b_local, (const int*)b,DATA_LENGTH*sizeof(int));
    ....

        memcpy((int*)c, c_local, DATA_LENGTH*sizeof(int));
}
