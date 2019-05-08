
#ifndef NLMS_FILTER_H
#define NLMS_FILTER_H

// Includes
#include "adaptive_filter.h"

class nlms_filter: public adaptive_filter
{

	protected:
		virtual void update_coefs(short* coefs, short* noise_buf, short step_size, short err);

	public:
		nlms_filter();
		~nlms_filter();

};

#endif // NLMS_FILTER_H


