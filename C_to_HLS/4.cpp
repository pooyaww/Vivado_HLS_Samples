#include <string.h>
#define DATA_LENGTH 1024
void vector_addition(int a[DATA_LENGTH], int b[DATA_LENGTH], int c[DATA_LENGTH]) {

#pragma HLS INTERFACE s_axilite port=return bundle=control_bus

#pragma HLS INTERFACE s_axilite port=a bundle=control_bus
#pragma HLS INTERFACE s_axilite port=b bundle=control_bus
#pragma HLS INTERFACE s_axilite port=c bundle=control_bus

#pragma HLS INTERFACE m_axi depth=16 port=a bundle=bus_port
#pragma HLS INTERFACE m_axi depth=16 port=b bundle=bus_port
#pragma HLS INTERFACE m_axi depth=16 port=c bundle=bus_port



    int a_local[DATA_LENGTH];
    int b_local[DATA_LENGTH];
    int c_local[DATA_LENGTH];

    memcpy(a_local, ( int*)a, DATA_LENGTH*sizeof(int));
    memcpy(b_local, ( int*)b, DATA_LENGTH*sizeof(int));

    for (int i = 0; i < DATA_LENGTH; i++) {
#pragma HLS PIPELINE
        c_local[i] = a_local[i]+b_local[i];
    }


    memcpy((int*)c, c_local, DATA_LENGTH*sizeof(int));
}
