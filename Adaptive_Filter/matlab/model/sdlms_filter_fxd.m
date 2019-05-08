
classdef sdlms_filter_fxd < adaptive_filter_fxd

	methods (Access = public)
		function obj = sdlms_filter_fxd()
			obj = obj@adaptive_filter_fxd();
		end	
	end
	
	methods (Access = protected)
		function coefs = update_coefs(obj, coefs, noise_buf, step_size, leakage, err)		
			% Compute update scale factor
			scaling = 2^-(obj.filter_params.num_coef_bits-1); % Not sure where the -3 factor comes from. You can tune it to converge faster/slower.
		
			noise_buf_idx = length(noise_buf);
			for ii = 1:length(coefs)
				% Compute signum of data
				if (noise_buf(noise_buf_idx) > 0)
					noise_buf_sgn = 1;
				elseif (noise_buf(noise_buf_idx) < 0)
					noise_buf_sgn = -1;
				else
					noise_buf_sgn = 0;
				end
				
				coefs(ii) = coefs(ii) + floor(scaling*step_size * err * noise_buf_sgn); % This node is 2x data_width + coef_width
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