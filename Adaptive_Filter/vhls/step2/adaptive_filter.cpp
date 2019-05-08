
#include <iostream>
using namespace std;
#include "adaptive_filter.h"

// Constructors
adaptive_filter::adaptive_filter()
{
	step_size = 33;
}

// Setters and getters
void adaptive_filter::set_coefs(short* new_coefs)
{
	int ii = 0;
	for (ii = 0; ii < NUM_COEFS; ii++)
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
	cout << "Number of filter coefficients: " << NUM_COEFS << endl;
	cout << "Adaptive algorithm step size: "  << step_size << endl;
}

void adaptive_filter::print_coefs()
{
	int ii = 0;

	cout << "Coefficients = ";
	for (ii = 0; ii < NUM_COEFS; ii++)
	{
		cout << coefs[ii];
		if (ii < NUM_COEFS-1)
			cout << ", ";
		else
			cout << endl;
	}
}

void adaptive_filter::print_noise_buf()
{
	int ii = 0;

	cout << "Noise buffer contents = ";
	for (ii = 0; ii < NUM_COEFS; ii++)
	{
		cout << noise_buf[ii];
		if (ii < NUM_COEFS-1)
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
	// Nothing to do
}

// Data processing helper function
void adaptive_filter::update_buf(short* buf, short new_sample)
{
	int ii = 0;

	for (ii = NUM_COEFS-1; ii > 0; ii--)
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
	noise_buf_idx = NUM_COEFS-1;
	main_fir_loop: for (coef_idx = 0; coef_idx < NUM_COEFS-1; coef_idx++)
	{
		acc += coefs[coef_idx] * noise_buf[noise_buf_idx];
		noise_buf_idx--;
	}

	filter_output = acc >> (sizeof(short)*8); // Could round here

	return filter_output;
}







// Uncomment me for LMS filter (HLS BUG)
/*void adaptive_filter::update_coefs(short* coefs, short* noise_buf, short step_size, short err)
{
	int   ii            = 0;
	int   noise_buf_idx = NUM_COEFS-1;
	long  tmp           = 0;
	long  tmp2          = 0;

	for (ii = 0; ii < NUM_COEFS; ii++)
	{
		// Update equation
		tmp = (long)step_size * (long)err * (long)noise_buf[noise_buf_idx]; // This node is 2x data_width + coef_width
		tmp = tmp >> (sizeof(short)*8+sizeof(short)*8-2);

		// Saturate output if coefficients get too big
		tmp2 = (long)coefs[ii] + tmp;
		if (tmp2 > (1 << ((sizeof(short)*8-1)-1)))
			coefs[ii] = (1 << ((sizeof(short)*8-1)-1));
		else if (tmp2 < -(1 << (sizeof(short)*8-1)))
			coefs[ii] = -(1 << (sizeof(short)*8-1));
		else
			coefs[ii] = tmp2;

		// Increment noise buffer
		noise_buf_idx = noise_buf_idx - 1;
	}
}*/


// Uncomment me for NLMS filter (HLS BUG)
void adaptive_filter::update_coefs(short* coefs, short* noise_buf, short step_size, short err)
{
	int   ii            = 0;
	int   noise_buf_idx = NUM_COEFS-1;
	long  tmp           = 0;
	long  tmp2          = 0;
	int   l2norm        = 0;

	// Compute L2 norm of the noise buffer
	for (ii = 0; ii < NUM_COEFS; ii++)
	{
		l2norm += (int)noise_buf[ii] * (int)noise_buf[ii];
	}
	l2norm >>= sizeof(short)*8;

	for (ii = 0; ii < NUM_COEFS; ii++)
	{

		// Update equation
		tmp = (long)step_size * (long)err * (long)noise_buf[noise_buf_idx]; // This node is 2x data_width + coef_width
		tmp /= l2norm;
		tmp = tmp >> (sizeof(short)*8-2);

		// Saturate output if coefficients get too big
		tmp2 = (long)coefs[ii] + tmp;
		if (tmp2 > (1 << ((sizeof(short)*8-1)-1)))
			coefs[ii] = (1 << ((sizeof(short)*8-1)-1));
		else if (tmp2 < -(1 << (sizeof(short)*8-1)))
			coefs[ii] = -(1 << (sizeof(short)*8-1));
		else
			coefs[ii] = tmp2;

		// Increment noise buffer
		noise_buf_idx = noise_buf_idx - 1;
	}
}

