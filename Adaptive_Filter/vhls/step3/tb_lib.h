
#ifndef TB_LIB_H
#define TB_LIB_H

// Defines
#define STATUS_SUCCESS 0
#define STATUS_FAILURE -1

using namespace std;
#include <string>

class tb_lib
{

	protected:

		// Data vectors
		short* desired;
		short* noise;
		short* signal_with_noise;
		short* output;

		// Control information
		int    num_samples_to_test;
		bool   do_write_files;

		// File names
		string desired_fname;
		string noise_fname;
		string output_fname;

		// Data processing helper functions
		int read_file(string fname, short* data);
		void run_test(short step_size);
		int write_file(string fname, short* data);

	public:

		// Constructors
		tb_lib(bool init_do_write_files, string init_desired_fname, string init_noise_fname, string init_output_fname, int init_num_samples_to_test);

		// Setters and Getters
		void set_do_write_files(bool new_do_write_files);
		bool get_do_write_files();
		short* get_desired();
		short* get_noise();
		short* get_signal_with_noise();
		short* get_output();

		// Status and debugging
		void print_uut_params();
		void print_statistics();

		// Data processing
		int run_all(short step_size);

		// Destructors
		~tb_lib();

};

#endif // TB_LIB_H


