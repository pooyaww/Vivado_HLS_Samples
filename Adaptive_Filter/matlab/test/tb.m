function tb(algo_and_test_str)
%
% Filename:     tb.m
% Author:       bwiec
% Create date:  01:44:01, 1 September 2015
% Description:  The purpose of this script is to run adaptive filter models, analyze their,
%               performance, and generate stimulus files (used by VHLS and SysGen) and 'golden'
%               output files (which can be used for further analysis).
% Known Issues:
%               - RLS algorithm only implemented in floating point and it is not yet in proper
%                 coding style for conversion to fixed point.
%               - RLS performance is still not good enough to be confident its implementation
%                 is working correctly.
%               - None of the algorithms work very well for the echo cancellation test as it is
%                 currently written. I believe this is because of improperly formed test vectors.
% Notes:
%               - None
% To Do:
%               - Fix RLS algorithm
%               - Implement RLS in fixed point
%               - Fix echo cancellation
%

	% Parse input string (Should do some error checking here)
	algo_and_test_cellarray = strsplit(algo_and_test_str, '_');
	algorithm               = char(algo_and_test_cellarray(1));
	test                    = char(algo_and_test_cellarray(2));

	% Dependency paths
	addpath('../model');
	addpath('../util');

	% Testbench control parameters (can be edited by the user)
	GEN_PLOTS       = 0; % Generate plots for algorithm analysis
	WRITE_FILES     = 1; % Write output files to be used by VHLS (only applicable for fixed point algorithms)
	WAIT_ON_USER    = 0; % After each iteration, wait for the user before resuming next test
	NUM_DATA_BITS   = 16;
	NUM_COEF_BITS   = 16;
	NUM_COEFS       = 16;
	NUM_SAMPLES     = 65536;
	
	if (WRITE_FILES)
		TARGET_DIR = '../../data/';
		if (~exist(TARGET_DIR))
			mkdir(TARGET_DIR);
		end
		if (~exist([TARGET_DIR '/stim/']))
			mkdir([TARGET_DIR '/stim/']);
		end
		if (~exist([TARGET_DIR '/output/matlab/']))
			mkdir([TARGET_DIR '/output/matlab/']);
		end
			
	end
	
	% Constant parameters
	n = 1:NUM_SAMPLES;

	disp('------------------------------------------------------');
	disp('- Adaptive Filter Verification                       -');
	disp('------------------------------------------------------');
	disp(' ');
	disp('Test parameters:');
	disp(['    Number of samples in test vectors: ' num2str(NUM_SAMPLES)]);
	disp('------------------------------------------------------');
	disp(' ');
	
	switch test
		case 'smoke'
			Fs                   = 100e6;
			f1                   = 3e6;
			f2                   = 20e6;
			d                    = 0.7.*sin(2*pi*f1*n/Fs);
			noise                = 0.1*sin(2*pi*f2*n/Fs);
			params.init_coefs    = fir1(NUM_COEFS-1, 0.4); % Initial coefficients
			params.step_size     = 0.01;          % Step size
			params.leakage       = 0.01;          % Leakage factor (only applicable to llms and lnlms)
			params.num_data_bits = NUM_DATA_BITS;
			params.num_coef_bits = NUM_COEF_BITS;
		case 'noiseCancellation'
			Fs                   = 100e6;
			f1                   = 3e6;
			d                    = 0.6.*sin(2*pi*f1*n/Fs);
			noise                = 0.3*rand(1,NUM_SAMPLES);
			params.init_coefs    = fir1(NUM_COEFS-1, 0.4); % Initial coefficients
			params.step_size     = 0.01;          % Step size
			params.leakage       = 0.01;          % Leakage factor (only applicable to llms and lnlms)
			params.num_data_bits = NUM_DATA_BITS;
			params.num_coef_bits = NUM_COEF_BITS;
		case 'echoCancellation' % None of these algorithms are very good because signal is non-stationary
			Fs                   = 50e3;
			f1                   = 886;
			f2                   = 1.25846e6;
			f3                   = 3e6;
			f4                   = 8.68132e6;
			f5                   = 9.08181e6;
			d                    = 0.1.*sin(2*pi*f1*n/Fs) + 0.1.*sin(2*pi*f2*n/Fs) + 0.1.*sin(2*pi*f3*n/Fs) + 0.1.*sin(2*pi*f4*n/Fs) + 0.1.*sin(2*pi*f5*n/Fs);
			d                    = d .* [zeros(1, NUM_SAMPLES/8), [NUM_SAMPLES/8:-1:1] .* 8/NUM_SAMPLES .* ones(1, NUM_SAMPLES/8), zeros(1, 3/4*NUM_SAMPLES)];
			d                    = d + 0.001 .* rand(1, NUM_SAMPLES);
			noise                = [zeros(1, 3*NUM_SAMPLES/8), d(NUM_SAMPLES/8:2*NUM_SAMPLES/8), zeros(1, NUM_SAMPLES/2-1)];
			noise                = noise + 0.008 .* rand(1, NUM_SAMPLES);
			coefs                = [-0.163974280295808738650009672710439190269, 0.079070801416879027412321079282264690846, 0.093964537910656370511830459690827410668, 0.11839526821891047103640914883726509288, 0.14389918450608182864947082180151483044, 0.162426962134689018002475791035976726562, 0.169148003437515792590772889525396749377, 0.162426962134689018002475791035976726562, 0.14389918450608182864947082180151483044, 0.11839526821891047103640914883726509288, 0.093964537910656370511830459690827410668, 0.079070801416879027412321079282264690846, -0.163974280295808738650009672710439190269];
			noise                = filter(coefs,1, noise) ./ 2;
			params.init_coefs    = fir1(8192*4, 0.4); % Initial coefficients
			params.step_size     = 0.000005;          % Step size
			params.leakage       = 0.01;          % Leakage factor (only applicable to llms and lnlms)
			params.num_data_bits = NUM_DATA_BITS;
			params.num_coef_bits = NUM_COEF_BITS;
		otherwise
			error('Illegal test.');
		end
	
	for is_fxd_pt = 0:1
		switch algorithm
			case 'lms'
				if (is_fxd_pt)
					uut_inst = lms_filter_fxd();
				else
					uut_inst = lms_filter();
				end
			case 'nlms'
				if (is_fxd_pt)
					uut_inst = nlms_filter_fxd();
				else
					uut_inst = nlms_filter();
				end
			case 'selms'
				if (is_fxd_pt)
					uut_inst = selms_filter_fxd();
				else
					uut_inst = selms_filter();
				end
			case 'sdlms'
				if (is_fxd_pt)
					uut_inst = sdlms_filter_fxd();
				else
					uut_inst = sdlms_filter();
				end
			case 'sslms'
				if (is_fxd_pt)
					uut_inst = sslms_filter_fxd();
				else
					uut_inst = sslms_filter();
				end
			case 'llms'
				if (is_fxd_pt)
					uut_inst = llms_filter_fxd();
				else
					uut_inst = llms_filter();
				end
			case 'lnlms'
				if (is_fxd_pt)
					uut_inst = lnlms_filter_fxd();
				else
					uut_inst = lnlms_filter();
				end
			case 'rls'
				if (is_fxd_pt)
					error('Fixed point RLS not yet implemented');
				else
					uut_inst = rls_filter();
					params.leakage = 0.0005*eye(16); % Identity matrix
				end
			otherwise
				error('Illegal algorithm.');
		end
	
		if (is_fxd_pt)
			desired_fname = [TARGET_DIR '/stim/'   algorithm '_' test '_fxd_desired.dat'];
			noise_fname   = [TARGET_DIR '/stim/'   algorithm '_' test '_fxd_noise.dat'];
			output_fname  = [TARGET_DIR '/output/matlab/' algorithm '_' test '_fxd_output.dat'];
			tb_lib_inst    = tb_lib_fxd(GEN_PLOTS, WRITE_FILES, desired_fname, noise_fname, output_fname, uut_inst);
			disp(['Fixed point ' test ' test using the ' algorithm ' algorithm.']);
		else
			desired_fname = [TARGET_DIR '/stim/'   algorithm '_' test '_flt_desired.dat'];
			noise_fname   = [TARGET_DIR '/stim/'   algorithm '_' test '_flt_noise.dat'];
			output_fname  = [TARGET_DIR '/output/matlab/' algorithm '_' test '_flt_output.dat'];
			tb_lib_inst   = tb_lib(GEN_PLOTS, WRITE_FILES, desired_fname, noise_fname, output_fname, uut_inst);
			disp(['Floating point ' test ' test using the ' algorithm ' algorithm.']);
		end
				
		tb_run_test(tb_lib_inst, params, d, noise, WAIT_ON_USER);
		disp('------------------------------------------------------');
		disp(' ');
				
		% Cleanup
		clear uut_inst;
		clear tb_lib_inst;
	end
	
	disp('Adaptive Filter Verification complete!');

	% Environment cleanup
	rmpath('../util');
	rmpath('../model');

end

