
#ifndef ADAPTIVE_FILTER_H
#define ADAPTIVE_FILTER_H

// These defines are necessary since HLS doesn't support dynamic stuff
#define LMS_ALGO   0
#define NLMS_ALGO  1
#define SELMS_ALGO 2
#define SDLMS_ALGO 3
#define SSLMS_ALGO 4
#define LLMS_ALGO  5
#define LNLMS_ALGO 6
#define WHICH_ALGO NLMS_ALGO // Pick one of the above
#define NUM_COEFS  16

class adaptive_filter
{

	protected:

		// Coefficient parameters
		short coefs[NUM_COEFS];

		// Data parameters
		short noise_buf[NUM_COEFS];

		// Adaption algorithm tuning parameters

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
		short run_filter(short signal_with_noise, short noise, short step_size);

		// Destructors
		virtual ~adaptive_filter();

};

#endif // ADAPTIVE_FILTER_H


