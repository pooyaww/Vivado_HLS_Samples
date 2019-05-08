
#ifndef ADAPTIVE_FILTER_H
#define ADAPTIVE_FILTER_H

#define NUM_COEFS  16

class adaptive_filter
{

	protected:

		// Coefficient parameters
		short coefs[NUM_COEFS];

		// Data parameters
		short noise_buf[NUM_COEFS];

		// Adaption algorithm tuning parameters
		short step_size;

		// Data processing helper functions
		void update_buf(short* buf, short new_sample);
		short data_filter(short* coefs, short* noise_buf);
		//virtual void update_coefs(short* coefs, short* noise_buf, short step_size, short err) = 0;
		void update_coefs(short* coefs, short* noise_buf, short step_size, short err); // HLS bug

	public:

		// Constructors
		adaptive_filter();

		// Setters and getters
		void set_coefs(short* new_coefs);
		short* get_coefs();
		void set_step_size(short new_step_size);
		short get_step_size();

		// Status and debugging
		void print_filter_params();
		void print_coefs();
		void print_noise_buf();

		// Data processing
		short run_filter(short signal_with_noise, short noise);

		// Destructors
		virtual ~adaptive_filter();

};

#endif // ADAPTIVE_FILTER_H


