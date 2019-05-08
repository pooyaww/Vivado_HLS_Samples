
classdef selms_filter_fxd < adaptive_filter_fxd

	methods (Access = public)
		function obj = selms_filter_fxd()
			obj = obj@adaptive_filter_fxd();
		end	
	end
	
	methods (Access = protected)
		function coefs = update_coefs(obj, coefs, noise_buf, step_size, leakage, err)
		
            % Compute signum of error
			if (err > 0)
				err_sgn = 1;
			elseif (err < 0)
				err_sgn = -1;
			else
				err_sgn = 0;
			end
				
			% Compute update scale factor
			scaling = 2^-(obj.filter_params.num_coef_bits-1); % Not sure where the -3 factor comes from. You can tune it to converge faster/slower.

			noise_buf_idx = length(noise_buf);
			for ii = 1:length(coefs)
				coefs(ii) = coefs(ii) + floor(scaling * step_size * err_sgn * noise_buf(noise_buf_idx)); % This node is 2x data_width + coef_width
				if (coefs(ii) > 2^(obj.filter_params.num_coef_bits-1)-1) % Saturate output if it gets too big
					coefs(ii) = 2^(obj.filter_params.num_coef_bits-1)-1;
				elseif (coefs(ii) < -2^(obj.filter_params.num_coef_bits-1))
					coefs(ii) = -2^(obj.filter_params.num_coef_bits-1);
				end
				noise_buf_idx = noise_buf_idx - 1;
			end
			
		end
		
	end

end

