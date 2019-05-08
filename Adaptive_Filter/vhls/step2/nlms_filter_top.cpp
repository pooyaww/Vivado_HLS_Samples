
// Includes
#include "nlms_filter.h"

short nlms_filter_top(short signal_with_noise, short noise, short step_size)
{
	static nlms_filter nlms_filter_inst;
	
	nlms_filter_inst.set_step_size(step_size);
	return nlms_filter_inst.run_filter(signal_with_noise, noise);
}

