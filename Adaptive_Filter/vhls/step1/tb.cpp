
// Includes
#include <iostream>
using namespace std;
#include "lms_filter.h"
#include "nlms_filter.h"
#include "tb_lib.h"

// Global parameters and initialization
#define DO_WRITE_FILES      1
#define NUM_SAMPLES_TO_TEST 65536
#define NUM_COEFS           16
#define STEP_SIZE           33
#define LMS_DESIRED_FNAME   "../../../../../matlab/stim/lms_desired.dat"
#define NLMS_DESIRED_FNAME  "../../../../../matlab/stim/nlms_desired.dat"
#define LMS_NOISE_FNAME     "../../../../../matlab/stim/lms_noise.dat"
#define NLMS_NOISE_FNAME    "../../../../../matlab/stim/nlms_noise.dat"
#define LMS_OUTPUT_FNAME    "../../../../result/lms_output.dat"
#define NLMS_OUTPUT_FNAME   "../../../../result/nlms_output.dat"
#define RUN_LMS_SMOKE_TEST  1
#define RUN_NLMS_SMOKE_TEST 1

// Created with matlab fir1(15, 0.4)
static short init_coefs[NUM_COEFS] = { 0,     183,  259, -541,
                                      -1665,  0,    6025, 12124,
                                       12124, 6025, 0,   -1665,
                                      -541,   259,  183,  0};

int main()
{
	// Create objects
	lms_filter*  lms_filter_inst  = new lms_filter();
	nlms_filter* nlms_filter_inst = new nlms_filter();
	tb_lib*      tb_lib_lms_inst  = new tb_lib(DO_WRITE_FILES, LMS_DESIRED_FNAME, LMS_NOISE_FNAME, LMS_OUTPUT_FNAME, lms_filter_inst, NUM_SAMPLES_TO_TEST);
	tb_lib*      tb_lib_nlms_inst = new tb_lib(DO_WRITE_FILES, NLMS_DESIRED_FNAME, NLMS_NOISE_FNAME, NLMS_OUTPUT_FNAME, nlms_filter_inst, NUM_SAMPLES_TO_TEST);

	// Set test parameters
	lms_filter_inst->set_num_coefs(NUM_COEFS);
	nlms_filter_inst->set_num_coefs(NUM_COEFS);
	lms_filter_inst->set_coefs(init_coefs);
	nlms_filter_inst->set_coefs(init_coefs);
	lms_filter_inst->set_step_size(STEP_SIZE);
	nlms_filter_inst->set_step_size(STEP_SIZE);

	// Run tests
	if (RUN_LMS_SMOKE_TEST)
	{
		tb_lib_lms_inst->run_all();
	}

	if (RUN_NLMS_SMOKE_TEST)
	{
		tb_lib_nlms_inst->run_all();
	}

	// Cleanup
	delete lms_filter_inst;
	delete tb_lib_lms_inst;
	delete nlms_filter_inst;
	delete tb_lib_nlms_inst;

	return 0;
}

