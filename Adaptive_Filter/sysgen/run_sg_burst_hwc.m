%
% Filename:     run_sg_burst_hwc.m
% Author:       bwiec
% Create date:  01:44:01, 1 September 2015
% Description:  The purpose of this script is to build then run a SysGen hardware co-sim model
%               and write the results to a file.
% Known Issues:
%               - None
% Notes:
%               - HWC = Hardware Co-Simulation
%               - When running HWC, this script assumes you have a KC705 connected to the host
%                 via JTAG and that the board is powered on.
%               - The script first generates a bitstream from the model for burst-mode JTAG
%                 hardware co-simulation and includes the option to create a testbench. When
%                 you do this, sysgen generates .dat test vectors for all gateway blocks and
%                 also a .m 'testbench' script in the ./netlist directory. When you run the HWC,
%                 this .m script runs the HWC and then compares the results against the .dat files
%                 and reports whether or not any mismatches occurred. This script does not, however,
%                 expose the actual data from the HWC result. In an effort to avoid the need to
%                 modify this testbench .m file (or write one from scratch), this script runs the HWC
%                 testbench script. If there is a mismatch, that script will error out. Otherwise,
%                 the data from HWC is identical to that in the .dat files so this script reads the
%                 .dat files and uses them as the output of sysgen.
%
% To Do:
%               - None
%

% Environment setup
clear all;
close all;
addpath('../matlab/util');

% User-defined constants
GEN_PLOTS                = 0;   % Whether or not matlab will generate plots of output signals
WRITE_FILES              = 1;   % Whether or not to write output data to a file
WAIT_ON_USER             = 1;   % Whether or not to wait for the user to evaluate results before returning
STEP_SIZE                = 328; % Step size of adaptive algorithm (while not used in the script, the simulink model that builds the HWC model depends on this)
USE_SW_SIM               = 0;   % For debugging/testing. Setting to 1 will cause the script to use software simulink simulation instead of HWC
CYCLES_PER_OUTPUT_SAMPLE = 60;  % This must be set based on the II of the HLS implementation for running the simulation for the proper number of clock cycles

% DON'T TOUCH constants
TESTS                    = {'smoke', 'noise_cancellation', 'echo_cancellation'};
ALGOS                    = {'lms', 'nlms', 'selms', 'sdlms', 'sslms', 'llms', 'lnlms'};
STIM_FPATH               = '../data/stim/';
HLS_OUTPUT_FPATH         = '../data/output/vhls/';
SG_OUTPUT_FPATH          = '../data/output/sg/';

% Warnings
disp(['NOTE! CYCLES_PER_OUTPUT_SAMPLE currently set to ' num2str(CYCLES_PER_OUTPUT_SAMPLE)]);
disp('If this does not correspond to the II of the current HLS implementation, the results from this simulation will be incorrect.');
disp('CYCLES_PER_OUTPUT_SAMPLE will vary with the algorithm chosen.');
disp('NOTE! Before running this script, you must have your development board connected via jtag.');

if (WAIT_ON_USER)
	input('Press the return key when the board set up is complete.');
end

for ii = 1:length(TESTS)
	for jj = 1:length(ALGOS) % We only run sysgen/hls on one test/algo at a time due to VHLS limitations. So search for which one we ran

		% Check if files exist for this test/algorithm
		stim_desired_fname = char(strcat(STIM_FPATH,       ALGOS(jj), '_', TESTS(ii), '_fxd_desired.dat'));
		stim_noise_fname   = char(strcat(STIM_FPATH,       ALGOS(jj), '_', TESTS(ii), '_fxd_noise.dat'));
		hls_output_fname   = char(strcat(HLS_OUTPUT_FPATH, ALGOS(jj), '_', TESTS(ii), '_fxd_output.dat'));
		sg_output_fname    = char(strcat(SG_OUTPUT_FPATH,  ALGOS(jj), '_', TESTS(ii), '_fxd_output.dat'));
		
		if (exist(stim_desired_fname) && exist(stim_noise_fname) && exist(hls_output_fname))
		
			% Load stimulus and HLS outputs
			stim_desired = load(stim_desired_fname);
			stim_noise   = load(stim_noise_fname);
			hls_output   = load(hls_output_fname);
			hls_output   = [zeros(3,1); hls_output(1:end-3)]; % Compensate for extra zeros in simulation due to reset
			n            = 1:length(hls_output);
			
			% Setup and run sysgen simulation (to be replaced with hardware co-simulation)
			signal_with_noise_ts = timeseries(stim_desired + stim_noise, n);
			noise_ts             = timeseries(stim_noise, n);
			
			% Compute the number of clock cycles for which to run the simulation
			NUM_SIM_CYCLES = CYCLES_PER_OUTPUT_SAMPLE * length(stim_desired);
			
			% Run simulation
			if (USE_SW_SIM)
				disp('Running software simulation...');
				sim('burst_hwc.slx');
				sg_output = output_sg.Data(1:CYCLES_PER_OUTPUT_SAMPLE:end-1)';
				sg_output = [sg_output(2:end), sg_output(end)];
			else
			
				% Create .bit if it doesn't exist
				if (~exist('netlist/burst_hwc.bit'))
					disp('Generating .bit file HWC. This will take a while.')
					open('burst_hwc.slx');
					xlGenerateButton('burst_hwc/ System Generator');
				end
			
				% Run HWC
				disp('Running hardware co-simulation...');
				sg_output = sg_burst_hwc_tb(stim_noise, stim_desired+stim_noise, NUM_SIM_CYCLES);
				sg_output = [sg_output(1), sg_output];
				
			end
		
			% Calculate err between HLS output and sysgen output
			err = abs(hls_output' - sg_output);
			disp(['Maximum error: ' num2str(max(err(10:end)))]); % Avoid startup conditions
		
			% Generate plots
			if (GEN_PLOTS)
				figure(1);
				plot(n, hls_output, 'b', n, sg_output, 'g', n, err, 'r');
				title(['Output for ' char(TESTS(ii)) ' test using ' char(ALGOS(jj)) ' algorithm']);
				legend('Vivado HLS Output', 'Sysgen Hardware Co-Sim Output', 'Error');
			end
			
			% Write files
			if (WRITE_FILES)
				if (~exist(SG_OUTPUT_FPATH))
					mkdir(SG_OUTPUT_FPATH);
				end
			
				write_file(sg_output, sg_output_fname)
			end
			
			if (WAIT_ON_USER)
				input('Press the return key to continue...');
			end
			
			% Cleanup
			close all;
			clear stim_desired_fname;
			clear stim_noise_fname;
			clear hls_output_fname;
			clear stim_desired;
			clear stim_noise;
			clear hls_output;
			clear sg_output;
			clear err;
			clear n;
			
		end

	end
end

% Environment cleanup
rmpath('../matlab/util');

disp('Done!');

