
classdef adaptive_filter_fxd < adaptive_filter

	methods (Access = public)
	
		function obj = adaptive_filter_fxd()
			obj = obj@adaptive_filter();
        end
		
		function set_filter_params(obj, params)
			obj.filter_params.num_data_bits = params.num_data_bits;
			obj.filter_params.num_coef_bits = params.num_coef_bits;
			params.init_coefs = round(params.init_coefs .* 2^(params.num_coef_bits-1));
			params.step_size  = round(params.step_size  .* 2^(params.num_coef_bits-1));
			params.leakage    = round(params.leakage    .* 2^(params.num_coef_bits-1));
            set_filter_params@adaptive_filter(obj, params);
		end
		
		function print_filter_params(obj)
			disp(['Number of Data bits: ' num2str(obj.filter_params.num_data_bits)]);
			disp(['Number of Coefficient bits: ' num2str(obj.filter_params.num_coef_bits)]);
            print_filter_params@adaptive_filter(obj);
        end
        
        function num_data_bits = get_num_data_bits(obj)
            num_data_bits = obj.filter_params.num_data_bits;
        end
        
        function num_coef_bits = get_num_coef_bits(obj)
            num_coef_bits = obj.filter_params.num_coef_bits;
        end
		
		function dout = run_filter(obj, signal_with_noise, noise)
			
			% Error checking
            if (min(signal_with_noise) < -2^(obj.filter_params.num_data_bits-1) || max(signal_with_noise) > 2^(obj.filter_params.num_data_bits-1)-1 ||...
                min(noise) < -2^(obj.filter_params.num_data_bits-1) || max(noise) > 2^(obj.filter_params.num_data_bits-1)-1)
                error(['Input data must be integers in the range of [-' num2str(2^(obj.filter_params.num_data_bits-1)) ', ' num2str(2^(obj.filter_params.num_data_bits-1)-1) ']']);
            end
            
            dout = run_filter@adaptive_filter(obj, signal_with_noise, noise);
			
		end
		
	end
	
	methods (Access = protected)
	
		% Adaptive filter is broken into two parts; 1) the filtering of data and 2) the
		% update equation
		function filter_output = data_filter(obj, coefs, noise_buf)
			
			% Standard MAC FIR
            filter_output = data_filter@adaptive_filter(obj, coefs, noise_buf);
			
            % Put this output sample back to the same number of bits as the input
            filter_output = floor(filter_output * 2^-obj.filter_params.num_coef_bits);
            
		end
		
	end
	
	methods (Abstract, Access = protected)
		update_coefs(obj, coefs, noise_buf, step_size, err)
	end

end

