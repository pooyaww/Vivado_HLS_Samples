
classdef adaptive_filter < handle

	properties (Access = protected)
		filter_params
	end
	
	methods (Access = public)
	
		function obj = adaptive_filter()
		
			% Create an empty struct containing C Model parameters with some required members
			obj.filter_params = struct();
			
        end
		
		function set_filter_params(obj, params)
			obj.filter_params.init_coefs = params.init_coefs;
			obj.filter_params.step_size  = params.step_size;
			obj.filter_params.leakage    = params.leakage;
		end
		
		function print_filter_params(obj)
			disp(['Initial coefficients: ' num2str(obj.filter_params.init_coefs)]);
			disp(['Step size: ' num2str(obj.filter_params.step_size)]);
			%disp(['Leakage factor: ' num2str(obj.filter_params.leakage)]);
			disp(['Leakage factor: ' num2str(obj.filter_params.leakage(1))]); % Hack right now since we're using the 'leakage' as dual purpose for RLS algorithm
		end
		
		function dout = run_filter(obj, signal_with_noise, noise)
			
			% Error checking
			if (length(signal_with_noise) ~= length(noise))
				error('Input data and noise lengths are not equal.');
			end
			
			% Initialization
			coefs     = obj.filter_params.init_coefs;
			noise_buf = zeros(size(coefs));
			dout      = zeros(size(signal_with_noise));
			
			% Loop over input vector
			for ii = 1:length(signal_with_noise)
				% Update buffer
				noise_buf = obj.update_buf(noise_buf, noise(ii));
				
				% Filter this sample with current coefficient values
				filter_output = obj.data_filter(coefs, noise_buf);
				
				% Compute error
				err = signal_with_noise(ii) - filter_output;
				
				% Update coefficients
				coefs = obj.update_coefs(coefs, noise_buf, obj.filter_params.step_size, obj.filter_params.leakage, err);
				
				% Build output vector
				dout(ii) = err;
				
			end
			
		end
		
	end
	
	methods (Access = protected)
	
		function new_buf = update_buf(obj, old_buf, new_sample) % Should make me a circular buffer. For now, just shift data around is fine
			new_buf = [new_sample, old_buf(1:end-1)];
		end
	
		% Adaptive filter is broken into two parts; 1) the filtering of data and 2) the
		% update equation
		function filter_output = data_filter(obj, coefs, noise_buf)
		
			% Standard MAC FIR
			filter_output = 0;
			noise_buf_idx = length(noise_buf);
			for coef_idx = 1:length(coefs)
				filter_output = filter_output + coefs(coef_idx)*noise_buf(noise_buf_idx);
				noise_buf_idx = noise_buf_idx - 1;
			end
			
		end
		
	end
	
	methods (Abstract, Access = protected)
		update_coefs(obj, coefs, noise_buf, step_size, err)
	end

end

