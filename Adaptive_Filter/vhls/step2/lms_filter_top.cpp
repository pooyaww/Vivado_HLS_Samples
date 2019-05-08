
// Includes
#include "lms_filter.h"

short lms_filter_top(short signal_with_noise, short noise, short step_size)
{
	static lms_filter lms_filter_inst;
	
	lms_filter_inst.set_step_size(step_size);
	return lms_filter_inst.run_filter(signal_with_noise, noise);
}

