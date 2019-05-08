
// Includes
#include <iostream>
using namespace std;
#include "adaptive_filter.h"
#include "tb_lib.h"

// Global parameters and initialization
#define DO_WRITE_FILES      1
#define NUM_SAMPLES_TO_TEST 65536
#define WHICH_TEST          SMOKE
#define STEP_SIZE           328
#define INPUT_FPATH         "../../../../../../data/stim/"
#define OUTPUT_FPATH        "../../../../../../data/output/vhls/"
#if (WHICH_ALGO == LMS_ALGO)
	#define ALGO_STRING "lms"
#elif(WHICH_ALGO == NLMS_ALGO)
	#define ALGO_STRING "nlms"
#elif(WHICH_ALGO == SELMS_ALGO)
	#define ALGO_STRING "selms"
#elif(WHICH_ALGO == SDLMS_ALGO)
	#define ALGO_STRING "sdlms"
#elif(WHICH_ALGO == SSLMS_ALGO)
	#define ALGO_STRING "sslms"
#elif(WHICH_ALGO == LLMS_ALGO)
	#define ALGO_STRING "llms"
#elif(WHICH_ALGO == LNLMS_ALGO)
	#define ALGO_STRING "lnlms"
#else
	Illegal algorithm choice
#endif
#if (WHICH_TEST == SMOKE)
	#define TEST_STRING "smoke"
#endif
#define DESIRED_FNAME       INPUT_FPATH ALGO_STRING "_" TEST_STRING "_fxd_desired.dat"
#define NOISE_FNAME         INPUT_FPATH ALGO_STRING "_" TEST_STRING "_fxd_noise.dat"
#define OUTPUT_FNAME        OUTPUT_FPATH ALGO_STRING "_" TEST_STRING "_fxd_output.dat"

int main()
{
	int status = 0;

	cout << "------------------------------------------------------" << endl;
	cout << "Fixed point " << TEST_STRING << " test using the " << ALGO_STRING << " algorithm." << endl;
	cout << "Running test with the following uut parameters:" << endl;
	cout << "Number of Data bits: " << sizeof(short)*8 << endl;
	cout << "Number of Coefficient bits: " << sizeof(short)*8 << endl;
	cout << "Step size: " << STEP_SIZE << endl;

	// Create objects
	tb_lib* tb_lib_inst = new tb_lib(DO_WRITE_FILES, DESIRED_FNAME, NOISE_FNAME, OUTPUT_FNAME, NUM_SAMPLES_TO_TEST);

	// Run tests
	status = tb_lib_inst->run_all(STEP_SIZE);
	if (status != STATUS_SUCCESS)
	{
		cout << "ERROR! Something went wrong during test." << endl;
		return STATUS_FAILURE;
	}

	// Cleanup
	delete tb_lib_inst;

	cout << "------------------------------------------------------" << endl << endl;

	return STATUS_SUCCESS;
}


