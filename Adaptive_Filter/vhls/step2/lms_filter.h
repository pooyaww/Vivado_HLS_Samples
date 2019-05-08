
#ifndef LMS_FILTER_H
#define LMS_FILTER_H

// Includes
#include "adaptive_filter.h"

class lms_filter: public adaptive_filter
{

	protected:
		virtual void update_coefs(short* coefs, short* noise_buf, short step_size, short err);

	public:
		lms_filter();
		~lms_filter();

};

#endif // LMS_FILTER_H


