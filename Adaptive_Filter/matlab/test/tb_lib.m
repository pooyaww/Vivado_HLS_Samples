
classdef tb_lib < handle

	properties (Access = protected)
		
		% UUT object
		uut
		
		% UUT parameters
		uut_params
		
		% Control information
		do_generate_plots
		do_write_files
		cur_fignum
		
		% Data vectors
		desired
		noise
		signal_with_noise
		output
		
		% File names
		desired_fname
		noise_fname
		output_fname
		
	end
	
	methods (Access = public)
		
		function obj = tb_lib(do_generate_plots, do_write_files, desired_fname, noise_fname, output_fname, uut)
		
			% Initialize control information
			if (isnumeric(do_generate_plots) && ((do_generate_plots == 0) || (do_generate_plots == 1)))
				obj.do_generate_plots = do_generate_plots;
			else
				error('do_generate_plots must be either 0 or 1');
			end

			if (isnumeric(do_write_files) && ((do_write_files == 0) || (do_write_files == 1)))
				obj.do_write_files = do_write_files;
			else
				error('do_write_files must be either 0 or 1');
			end
			obj.cur_fignum = 1;
			
			% Initialize file names
			obj.desired_fname = desired_fname;
			obj.noise_fname   = noise_fname;
			obj.output_fname  = output_fname;
			
			% Initialize data vectors
			obj.desired           = 0;
			obj.noise             = 0;
			obj.signal_with_noise = 0;
			obj.output            = 0;
			
			% Initialize adaptive filter instance
			obj.uut = uut;
			
		end
		
		function set_uut_params(obj, params)
			obj.uut.set_filter_params(params)
		end
		
		function set_desired(obj, desired)
			obj.desired = desired;
		end
		
		function desired = get_desired(obj)
			desired = obj.desired;
		end
		
		function set_noise(obj, noise)
			obj.noise = noise;
		end
		
		function noise = get_noise(obj)
			noise = obj.noise;
		end
		
		function signal_with_noise = get_signal_with_noise(obj)
			signal_with_noise = obj.signal_with_noise;
		end
		
		function output = get_output(obj)
			output = obj.output;
		end
		
		function run_test(obj)
			
			% Error checking
			if (length(obj.desired) ~= length(obj.noise))
				error('Input vectors are not the same length.');
			end
			
			disp(['Running test with the following uut parameters:']);
			obj.print_uut_params();
			
			% Combine signal with noise
			obj.set_signal_with_noise(obj.desired + obj.noise);
			
			% Filter data
			obj.output = obj.uut.run_filter(obj.signal_with_noise, obj.noise);
			
			disp('Test complete!');
			
		end
		
		function print_uut_params(obj)
			obj.uut.print_filter_params();
		end
		
		function print_statistics(obj)
			worst_mse = mse(obj.get_desired(), obj.get_signal_with_noise());
			this_mse  = mse(obj.get_desired(), obj.get_output());
			disp(['MSE = ' num2str(this_mse) ' (vs. ' num2str(worst_mse) ')']);
		end
		
		function generate_plots(obj)
			create_plot(obj, obj.desired, 'Desired signal');
			create_plot(obj, obj.noise, 'Noise');
			create_plot(obj, obj.signal_with_noise, 'Desired signal + noise');
			create_plot(obj, 10*log(abs(fftshift(fft(obj.signal_with_noise(3/4*end:end))))), 'Desired signal + noise spectrum (dB)'); % Only use the last 1/4 of the vector to estimate steady state response
			create_plot(obj, obj.output, 'Filter output');
			create_plot(obj, 10*log(abs(fftshift(fft(obj.output(3/4*end:end))))), 'Filter output spectrum (dB)');
			create_compare_plot(obj, obj.desired, obj.output, abs(obj.desired - obj.output), 'Desired signal vs Filter Output');
			legend('Desired','Filter output','Error');
			create_compare_plot(obj, 10*log(abs(fftshift(fft(obj.signal_with_noise(3/4*end:end))))), 10*log(abs(fftshift(fft(obj.output(3/4*end:end))))), zeros(size(obj.output(3/4*end:end))), 'Desired signal + noise vs Filter Output spectrum (dB)');
			legend('Desired signal + noise','Filter output','N/A');
		end
		
		function run_all(obj)
			
			obj.run_test();
			
			obj.print_statistics;
			
			if (obj.do_generate_plots)
				obj.generate_plots();
			end
			
			if (obj.do_write_files)
				write_file(obj.desired, obj.desired_fname);
				write_file(obj.noise, obj.noise_fname);
				write_file(obj.output, obj.output_fname)
			end
	
		end
		
	end
	
	methods (Access = protected)
		
		% Create a plot from data with a title and keep track of cur_fignum
		function create_plot(obj, data, fig_title)
			figure(obj.cur_fignum);
			obj.cur_fignum = obj.cur_fignum + 1;
			plot(data);
			title(fig_title);
		end
		
		function create_compare_plot(obj, data1, data2, err, fig_title)
			figure(obj.cur_fignum);
			obj.cur_fignum = obj.cur_fignum + 1;
			plot(...
				1:length(data1), data1, 'b', ...
				1:length(data2), data2, 'g', ...
				1:length(err),   err,   'r'  ...
			);
			title(fig_title);
		end
		
	end
	
	methods (Access = private)
		
		function set_signal_with_noise(obj, signal_with_noise)
			obj.signal_with_noise = signal_with_noise;
		end
		
	end

end

