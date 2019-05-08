
// Includes
#include "adaptive_filter.h"

short adaptive_filter_top(short signal_with_noise, short noise, short step_size)
{
	static adaptive_filter adaptive_filter_inst;
	
	return adaptive_filter_inst.run_filter(signal_with_noise, noise, step_size);
}

