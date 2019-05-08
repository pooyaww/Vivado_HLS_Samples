
// Includes
#include <iostream>
#include <fstream>
using namespace std;
#include "tb_lib.h"
#include "lms_filter_top.h"

// Constructors
tb_lib::tb_lib(bool init_do_write_files, string init_desired_fname, string init_noise_fname, string init_output_fname, int init_num_samples_to_test)
{
	num_samples_to_test = init_num_samples_to_test;
	do_write_files      = init_do_write_files;
	desired_fname       = init_desired_fname;
	noise_fname         = init_noise_fname;
	output_fname        = init_output_fname;

	desired             = new short[num_samples_to_test];
	noise               = new short[num_samples_to_test];
	signal_with_noise   = new short[num_samples_to_test];
	output              = new short[num_samples_to_test];
}

// Setters and Getters
void tb_lib::set_do_write_files(bool new_do_write_files)
{
	do_write_files = new_do_write_files;
}

bool tb_lib::get_do_write_files()
{
	return do_write_files;
}

short* tb_lib::get_desired()
{
	return desired;
}

short* tb_lib::get_noise()
{
	return noise;
}

short* tb_lib::get_signal_with_noise()
{
	return signal_with_noise;
}

short* tb_lib::get_output()
{
	return output;
}

// Status and debugging
void tb_lib::print_uut_params()
{
	// Not sure how to do this now
}

void tb_lib::print_statistics()
{
	int   ii          = 0;
	float diff        = 0;
	float diff_sq     = 0;
	float sum_diff_sq = 0;
	float mse         = 0;

	for (ii = 0; ii < num_samples_to_test; ii++)
	{
		diff         = desired[ii] - output[ii];
		diff_sq      = diff * diff;
		sum_diff_sq += diff_sq;
	}

	mse = 1/num_samples_to_test * sum_diff_sq;

	cout << "MSE: " << mse << endl;

}

// Data processing
void tb_lib::run_all(short step_size)
{
	cout << "Running test with the following parameters:" << endl;
	print_uut_params();

	// Read in stimulus
	read_file(desired_fname, desired);
	read_file(noise_fname, noise);

	// Execute test
	run_test(step_size);

	// Post-processing
	print_statistics();
	if (do_write_files)
		write_file(output_fname, output);

	cout << "Test complete!" << endl;
}

// Destructors
tb_lib::~tb_lib()
{
	delete desired;
	delete noise;
	delete signal_with_noise;
	delete output;
}

// Data processing helper functions
void tb_lib::read_file(string fname, short* data)
{
	int      ii   = 0;
	ifstream fid;

	fid.open(fname.c_str());
	if (fid.is_open())
	{
		while (fid >> data[ii])
		{
			if (ii >= num_samples_to_test-1)
				break;
			ii++;
		}

		if (ii < num_samples_to_test-1)
		{
			cout << "ERROR! " << fname << " does not contain " << num_samples_to_test << " samples. It has " << ii << " samples." << endl;
			return;
		}
		fid.close();
	}
	else
	{
		cout << "ERROR! Failed to open file " << fname << " for reading." << endl;
		return;
	}
}

void tb_lib::run_test(short step_size)
{
	int ii = 0;

	for (ii = 0; ii < num_samples_to_test; ii++)
	{
		signal_with_noise[ii] = desired[ii] + noise[ii];
		output[ii] = lms_filter_top(signal_with_noise[ii], noise[ii], step_size);
	}
}

void tb_lib::write_file(string fname, short* data)
{
	int ii = 0;
	ofstream fid;

	fid.open(fname.c_str());
	if (fid.is_open())
	{
		for (ii = 0; ii < num_samples_to_test; ii++)
		{
			fid << data[ii];
			fid << endl;
		}
		fid.close();
	}
	else
	{
		cout << "ERROR! Failed to open file " << output_fname << " for writing." << endl;
		return;
	}

}


