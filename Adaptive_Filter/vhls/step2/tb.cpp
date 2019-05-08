
// Includes
#include <iostream>
using namespace std;
#include "lms_filter.h"
#include "tb_lib.h"

// Global parameters and initialization
#define DO_WRITE_FILES      1
#define NUM_SAMPLES_TO_TEST 65536
#define STEP_SIZE           33
#define LMS_DESIRED_FNAME   "../../../../../matlab/stim/lms_desired.dat"
#define NLMS_DESIRED_FNAME  "../../../../../matlab/stim/nlms_desired.dat"
#define LMS_NOISE_FNAME     "../../../../../matlab/stim/lms_noise.dat"
#define NLMS_NOISE_FNAME    "../../../../../matlab/stim/nlms_noise.dat"
#define LMS_OUTPUT_FNAME    "../../../../result/lms_output.dat"
#define NLMS_OUTPUT_FNAME   "../../../../result/nlms_output.dat"
#define RUN_LMS_SMOKE_TEST  0 // You can only do one of these at a time thanks to HLS bug preventing inheritence
#define RUN_NLMS_SMOKE_TEST 1 // You can only do one of these at a time thanks to HLS bug preventing inheritence


// Created with matlab fir1(15, 0.4)
static short init_coefs[16] =  { 0,     183,  259, -541,
                                -1665,  0,    6025, 12124,
                                 12124, 6025, 0,   -1665,
                                -541,   259,  183,  0}; // How to initialize coef vector!?!

int main()
{
	// Run tests
	if (RUN_LMS_SMOKE_TEST)
	{
		tb_lib* tb_lib_lms_inst  = new tb_lib(DO_WRITE_FILES, LMS_DESIRED_FNAME, LMS_NOISE_FNAME, LMS_OUTPUT_FNAME, NUM_SAMPLES_TO_TEST);
		tb_lib_lms_inst->run_all(STEP_SIZE);
		delete tb_lib_lms_inst;
	}

	if (RUN_NLMS_SMOKE_TEST)
	{
		tb_lib* tb_lib_nlms_inst  = new tb_lib(DO_WRITE_FILES, NLMS_DESIRED_FNAME, NLMS_NOISE_FNAME, NLMS_OUTPUT_FNAME, NUM_SAMPLES_TO_TEST);
		tb_lib_nlms_inst->run_all(STEP_SIZE);
		delete tb_lib_nlms_inst;
	}

	return 0;
}


