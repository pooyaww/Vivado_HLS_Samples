
#include "nlms_filter.h"

nlms_filter::nlms_filter()
{
	// Just call superclass constructor
}

void nlms_filter::update_coefs(short* coefs, short* noise_buf, short step_size, short err)
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

nlms_filter::~nlms_filter()
{
	// Just call superclass destructor
}


