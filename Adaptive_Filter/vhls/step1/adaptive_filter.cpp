
#include <iostream>
using namespace std;
#include "adaptive_filter.h"

// Constructors
adaptive_filter::adaptive_filter()
{
	num_coefs     = 16;
	step_size     = 33;
	coefs         = new short[num_coefs];
	noise_buf     = new short[num_coefs];
}

// Setters and getters
void adaptive_filter::set_num_coefs(int new_num_coefs)
{
	delete coefs;
	delete noise_buf;
	num_coefs = new_num_coefs;
	coefs     = new short[num_coefs];
	noise_buf = new short[num_coefs];
}

int adaptive_filter::get_num_coefs()
{
	return num_coefs;
}

void adaptive_filter::set_coefs(short* new_coefs)
{
	int ii = 0;
	for (ii = 0; ii < num_coefs; ii++)
		coefs[ii] = new_coefs[ii];
}

short* adaptive_filter::get_coefs()
{
	return coefs;
}

void adaptive_filter::set_step_size(short new_step_size)
{
	step_size = new_step_size;
}
short adaptive_filter::get_step_size()
{
	return step_size;
}

// Status and debugging
void adaptive_filter::print_filter_params()
{
	cout << "Number of filter coefficients: " << num_coefs << endl;
	cout << "Adaptive algorithm step size: "  << step_size << endl;
}

void adaptive_filter::print_coefs()
{
	int ii = 0;

	cout << "Coefficients = ";
	for (ii = 0; ii < num_coefs; ii++)
	{
		cout << coefs[ii];
		if (ii < num_coefs-1)
			cout << ", ";
		else
			cout << endl;
	}
}

void adaptive_filter::print_noise_buf()
{
	int ii = 0;

	cout << "Noise buffer contents = ";
	for (ii = 0; ii < num_coefs; ii++)
	{
		cout << noise_buf[ii];
		if (ii < num_coefs-1)
			cout << ", ";
		else
			cout << endl;
	}
}

// Data processing
short adaptive_filter::run_filter(short signal_with_noise, short noise)
{
	short filter_output = 0;
	int   err_full      = 0;
	short err           = 0;

	// Update buffer
	update_buf(noise_buf, noise);

	// Filter this sample with current coefficient values
	filter_output = data_filter(coefs, noise_buf);

	// Compute error (saturate on overflow)
	err_full = signal_with_noise - filter_output;
	if (err_full > (1 << (sizeof(short)*8-1))-1)
		err = 2^(sizeof(short)*8-1)-1;
	else if (err_full < -(1 << (sizeof(short)*8-1)))
		err = -(1 << (sizeof(short)*8-1));
	else
		err = err_full;

	// Update coefficients
	update_coefs(coefs, noise_buf, step_size, err);

	return err;
}

// Destructors
adaptive_filter::~adaptive_filter()
{
	delete coefs;
	delete noise_buf;
}

// Data processing helper function
void adaptive_filter::update_buf(short* buf, short new_sample)
{
	int ii = 0;

	for (ii = num_coefs-1; ii > 0; ii--)
		buf[ii] = buf[ii-1];
	buf[0] = new_sample;
}

short adaptive_filter::data_filter(short* coefs, short* noise_buf)
{
	int   coef_idx      = 0;
	int   acc           = 0;
	short filter_output = 0;
	int   noise_buf_idx = 0;

	acc           = 0;
	noise_buf_idx = num_coefs-1;
	for (coef_idx = 0; coef_idx < num_coefs-1; coef_idx++)
	{
		acc += coefs[coef_idx] * noise_buf[noise_buf_idx];
		noise_buf_idx--;
	}

	filter_output = acc >> (sizeof(short)*8); // Could round here

	return filter_output;
}

