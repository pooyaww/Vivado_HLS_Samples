%
% Filename:     analyze_results.m
% Author:       bwiec
% Create date:  01:44:01, 1 September 2015
% Description:  The purpose of this script is to analyze all results from Matlab, VHLS, and SysGen.
% Known Issues:
%               - None
% Notes:
%               - HWC = Hardware Co-Simulation
%               - This script assumes that matlab, VHLS, and SysGen outputs have been generated
% To Do:
%               - Plot spectrums
%

% Environment setup
clear all;
close all;
addpath('../matlab/util');

% User-defined constants
GEN_PLOTS           = 1;  % Whether or not matlab will generate plots of output signals
NUM_DATA_BITS       = 16; % Number of bits 
SG_STARTUP_LATENCY  = 3;

% DON'T TOUCH constants
TESTS               = {'smoke', 'noise_cancellation', 'echo_cancellation'};
ALGOS               = {'lms', 'nlms', 'selms', 'sdlms', 'sslms', 'llms', 'lnlms'};
STIM_FPATH          = '../data/stim/';
MATLAB_OUTPUT_FPATH = '../data/output/matlab/';
HLS_OUTPUT_FPATH    = '../data/output/vhls/';
SG_OUTPUT_FPATH     = '../data/output/sg/';

for ii = 1:length(TESTS)
	for jj = 1:length(ALGOS) % We only run sysgen/hls on one test/algo at a time due to VHLS limitations. So search for which one we ran

		% Check if files exist for this test/algorithm
		stim_desired_flt_fname  = char(strcat(STIM_FPATH,          ALGOS(jj), '_', TESTS(ii), '_flt_desired.dat'));
		stim_desired_fxd_fname  = char(strcat(STIM_FPATH,          ALGOS(jj), '_', TESTS(ii), '_fxd_desired.dat'));
		stim_noise_flt_fname    = char(strcat(STIM_FPATH,          ALGOS(jj), '_', TESTS(ii), '_flt_noise.dat'));
		stim_noise_fxd_fname    = char(strcat(STIM_FPATH,          ALGOS(jj), '_', TESTS(ii), '_fxd_noise.dat'));
		matlab_output_flt_fname = char(strcat(MATLAB_OUTPUT_FPATH, ALGOS(jj), '_', TESTS(ii), '_flt_output.dat'));
		matlab_output_fxd_fname = char(strcat(MATLAB_OUTPUT_FPATH, ALGOS(jj), '_', TESTS(ii), '_fxd_output.dat'));
		hls_output_fxd_fname    = char(strcat(HLS_OUTPUT_FPATH,    ALGOS(jj), '_', TESTS(ii), '_fxd_output.dat'));
		sg_output_fxd_fname     = char(strcat(SG_OUTPUT_FPATH,     ALGOS(jj), '_', TESTS(ii), '_fxd_output.dat'));
		
		if (exist(stim_desired_flt_fname) && exist(stim_noise_flt_fname) && ...
			exist(stim_desired_fxd_fname) && exist(stim_noise_fxd_fname) && ...
			exist(hls_output_fxd_fname)   && exist(sg_output_fxd_fname))
			
			% Load data
			stim_desired_flt  = load(stim_desired_flt_fname);
			stim_desired_fxd  = load(stim_desired_fxd_fname)  .* 2^-(NUM_DATA_BITS-1);
			stim_noise_flt    = load(stim_noise_flt_fname);
			stim_noise_fxd    = load(stim_noise_fxd_fname)    .* 2^-(NUM_DATA_BITS-1);
			matlab_output_flt = load(matlab_output_flt_fname);
			matlab_output_fxd = load(matlab_output_fxd_fname) .* 2^-(NUM_DATA_BITS-1);
			hls_output_fxd    = load(hls_output_fxd_fname)    .* 2^-(NUM_DATA_BITS-1);
			sg_output_fxd     = load(sg_output_fxd_fname)     .* 2^-(NUM_DATA_BITS-1);
			n = 1:length(hls_output_fxd);
			
			% Compute errors
			err_stim_desired_fxd_vs_flt      = abs(stim_desired_flt  - stim_desired_fxd);
			err_stim_noise_fxd_vs_flt        = abs(stim_noise_flt    - stim_noise_fxd);
			err_matlab_output_fxd_vs_flt     = abs(matlab_output_flt - matlab_output_fxd);
			err_desired_vs_matlab_output_flt = abs(stim_desired_flt  - matlab_output_flt);
			err_desired_vs_matlab_output_fxd = abs(stim_desired_fxd  - matlab_output_fxd);
			err_desired_vs_hls_output_fxd    = abs(stim_desired_fxd  - hls_output_fxd);
			err_desired_vs_sg_output_fxd     = abs(stim_desired_fxd(1:end-SG_STARTUP_LATENCY)  - sg_output_fxd(SG_STARTUP_LATENCY+1:end));
			
			% Plot data
			if (GEN_PLOTS)
				
				% Plot time domain data
				figure(1);
				plot(n, stim_desired_flt, 'b', n, stim_desired_fxd, 'g', n, err_stim_desired_fxd_vs_flt, 'r');
				title('Desired signal');
				legend('Floating-Point', 'Fixed-Point', 'Error');
				this_mse  = mse(stim_desired_flt, stim_desired_fxd);
				annotation('textbox', [0.625 0.475 .3 .3], 'String', ['MSE = ' num2str(this_mse)], 'FitBoxToText', 'on', 'LineStyle', 'none');
				
				figure(2);
				plot(n, stim_noise_flt, 'b', n, stim_noise_fxd, 'g', n, err_stim_noise_fxd_vs_flt, 'r');
				title('Noise signal');
				legend('Floating-Point', 'Fixed-Point', 'Error');
				this_mse  = mse(stim_noise_flt, stim_noise_fxd);
				annotation('textbox', [0.625 0.475 .3 .3], 'String', ['MSE = ' num2str(this_mse)], 'FitBoxToText', 'on', 'LineStyle', 'none');
				
				figure(3);
				plot(n, matlab_output_flt, 'b', n, matlab_output_fxd, 'g', n, err_matlab_output_fxd_vs_flt, 'r');
				title('Matlab filter output signal');
				legend('Floating-Point', 'Fixed-Point', 'Error');
				this_mse  = mse(matlab_output_flt, matlab_output_fxd);
				annotation('textbox', [0.625 0.475 .3 .3], 'String', ['MSE = ' num2str(this_mse)], 'FitBoxToText', 'on', 'LineStyle', 'none');
				
				figure(4);
				plot                                                                               ...
				(                                                                                  ...
					n(1:end-SG_STARTUP_LATENCY), matlab_output_flt(1:end-SG_STARTUP_LATENCY), 'b', ...
					n(1:end-SG_STARTUP_LATENCY), matlab_output_fxd(1:end-SG_STARTUP_LATENCY), 'g', ...
					n(1:end-SG_STARTUP_LATENCY), hls_output_fxd(1:end-SG_STARTUP_LATENCY),    'm', ...
					n(1:end-SG_STARTUP_LATENCY), sg_output_fxd(SG_STARTUP_LATENCY+1:end),     'c'  ...
				);
				title('All filter output signals');
				legend('Matlab Floating-Point', 'Matlab Fixed-Point', 'HLS Fixed-Point', 'SysGen Fixed-Point');
				
				figure(5);
				plot(n, stim_desired_flt, 'b', n, matlab_output_flt, 'g', n, err_desired_vs_matlab_output_flt, 'r');
				title('Comparison of Matlab Floating-Point filter output to desired signal');
				legend('Desired', 'Output', 'Error');
				this_mse  = mse(stim_desired_flt, matlab_output_flt);
				annotation('textbox', [0.625 0.475 .3 .3], 'String', ['MSE = ' num2str(this_mse)], 'FitBoxToText', 'on', 'LineStyle', 'none');
				
				figure(6);
				plot(n, stim_desired_fxd, 'b', n, matlab_output_fxd, 'g', n, err_desired_vs_matlab_output_fxd, 'r');
				title('Comparison of Matlab Fixed-Point filter output to desired signal');
				legend('Desired', 'Output', 'Error');
				this_mse  = mse(stim_desired_fxd, matlab_output_fxd);
				annotation('textbox', [0.625 0.475 .3 .3], 'String', ['MSE = ' num2str(this_mse)], 'FitBoxToText', 'on', 'LineStyle', 'none');
				
				figure(7);
				plot(n, stim_desired_fxd, 'b', n, hls_output_fxd, 'g', n, err_desired_vs_hls_output_fxd, 'r');
				title('Comparison of HLS Fixed-Point filter output to desired signal');
				legend('Desired', 'Output', 'Error');
				this_mse  = mse(stim_desired_fxd, hls_output_fxd);
				annotation('textbox', [0.625 0.475 .3 .3], 'String', ['MSE = ' num2str(this_mse)], 'FitBoxToText', 'on', 'LineStyle', 'none');
				
				figure(8);
				plot                                                                              ...
				(                                                                                 ...
					n(1:end-SG_STARTUP_LATENCY), stim_desired_fxd(1:end-SG_STARTUP_LATENCY), 'b', ...
					n(1:end-SG_STARTUP_LATENCY), sg_output_fxd(SG_STARTUP_LATENCY+1:end),    'g', ...
					n(1:end-SG_STARTUP_LATENCY), err_desired_vs_sg_output_fxd,               'r'  ...
				);
				title('Comparison of SysGen Fixed-Point filter output to desired signal');
				legend('Desired', 'Output', 'Error');
				this_mse  = mse(stim_desired_fxd(1:end-SG_STARTUP_LATENCY), sg_output_fxd(SG_STARTUP_LATENCY+1:end));
				annotation('textbox', [0.625 0.475 .3 .3], 'String', ['MSE = ' num2str(this_mse)], 'FitBoxToText', 'on', 'LineStyle', 'none');
				
				% Compute spectrums of data (only use the last 1/4 of the vector to estimate steady state response)
				stim_desired_flt_spec  = abs(fftshift(fft(stim_desired_flt(3/4*end:end))));
				stim_desired_fxd_spec  = abs(fftshift(fft(stim_desired_fxd(3/4*end:end))));
				stim_noise_flt_spec    = abs(fftshift(fft(stim_noise_flt(3/4*end:end))));
				stim_noise_fxd_spec    = abs(fftshift(fft(stim_noise_fxd(3/4*end:end))));
				matlab_output_flt_spec = abs(fftshift(fft(matlab_output_flt(3/4*end:end))));
				matlab_output_fxd_spec = abs(fftshift(fft(matlab_output_fxd(3/4*end:end))));
				hls_output_fxd_spec    = abs(fftshift(fft(hls_output_fxd(3/4*end:end))));
				sg_output_fxd_spec     = abs(fftshift(fft(sg_output_fxd(3/4*end:end))));
				n = 1:length(hls_output_fxd_spec);
				
				% Plot spectrums of data
				figure(9);
				semilogy(n, stim_desired_flt_spec, 'b', n, stim_desired_fxd_spec, 'g');
				title('Desired signal spectrum');
				legend('Floating-Point', 'Fixed-Point');
				grid on;
				
				figure(10);
				semilogy(n, stim_noise_flt_spec, 'b', n, stim_noise_fxd_spec, 'g');
				title('Noise signal spectrum');
				legend('Floating-Point', 'Fixed-Point');
				grid on;
				
				figure(11);
				semilogy(n, matlab_output_flt_spec, 'b', n, matlab_output_fxd_spec, 'g');
				title('Matlab filter output signal spectrum');
				legend('Floating-Point', 'Fixed-Point');
				grid on;
				
				figure(12);
				semilogy                                                                                    ...
				(                                                                                       ...
					n(1:end-SG_STARTUP_LATENCY), matlab_output_flt_spec(1:end-SG_STARTUP_LATENCY), 'b', ...
					n(1:end-SG_STARTUP_LATENCY), matlab_output_fxd_spec(1:end-SG_STARTUP_LATENCY), 'g', ...
					n(1:end-SG_STARTUP_LATENCY), hls_output_fxd_spec(1:end-SG_STARTUP_LATENCY),    'm', ...
					n(1:end-SG_STARTUP_LATENCY), sg_output_fxd_spec(SG_STARTUP_LATENCY+1:end),     'c'  ...
				);
				title('All filter output signal spectrums');
				legend('Matlab Floating-Point', 'Matlab Fixed-Point', 'HLS Fixed-Point', 'SysGen Fixed-Point');
				grid on;
				
				figure(13);
				semilogy(n, stim_desired_flt_spec, 'b', n, matlab_output_flt_spec, 'g');
				title('Comparison of Matlab Floating-Point filter output to desired signal spectrums');
				legend('Desired', 'Output');
				grid on;
				
				figure(14);
				semilogy(n, stim_desired_fxd_spec, 'b', n, matlab_output_fxd_spec, 'g');
				title('Comparison of Matlab Fixed-Point filter output to desired signal spectrums');
				legend('Desired', 'Output');
				grid on;
				
				figure(15);
				semilogy(n, stim_desired_fxd_spec, 'b', n, hls_output_fxd_spec, 'g');
				title('Comparison of HLS Fixed-Point filter output to desired signal spectrums');
				legend('Desired', 'Output');
				grid on;
				
				figure(16);
				semilogy                                                                               ...
				(                                                                                      ...
					n(1:end-SG_STARTUP_LATENCY), stim_desired_fxd_spec(1:end-SG_STARTUP_LATENCY), 'b', ...
					n(1:end-SG_STARTUP_LATENCY), sg_output_fxd_spec(SG_STARTUP_LATENCY+1:end),    'g' ...
				);
				title('Comparison of SysGen Fixed-Point filter output to desired signal spectrums');
				legend('Desired', 'Output', 'Error');
				grid on;
				
			end
		
		end
		
		% Cleanup
		clear stim_desired_flt;
		clear stim_desired_fxd;
		clear stim_noise_flt;
		clear stim_noise_fxd;
		clear matlab_output_flt;
		clear matlab_output_fxd;
		clear hls_output_fxd;
		clear sg_output_fxd;
		clear n;
		clear err_stim_desired_fxd_vs_flt;
		clear err_stim_noise_fxd_vs_flt;
		clear err_matlab_output_fxd_vs_flt;
		clear err_desired_vs_matlab_output_flt;
		clear err_desired_vs_matlab_output_fxd;
		clear err_desired_vs_hls_output_fxd;
		clear err_desired_vs_sg_output_fxd;
		
	end
end

% Environment cleanup
rmpath('../matlab/util');

input('press return key to continue...');

