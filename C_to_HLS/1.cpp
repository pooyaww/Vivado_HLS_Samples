#define DATA_LENGTH 1024
void vector_add(int a[DATA_LENGTH], int b[DATA_LENGTH], int c[DATA_LENGTH]) {
    for (int i = 0; i &lt; DATA_LENGTH; i++) {
        c[i] = a[i]+b[i];
    }
}
