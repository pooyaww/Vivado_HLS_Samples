
classdef lnlms_filter_fxd < adaptive_filter_fxd

	methods (Access = public)
		function obj = lnlms_filter_fxd()
			obj = obj@adaptive_filter_fxd();
		end	
	end
	
	methods (Access = protected)
		function coefs = update_coefs(obj, coefs, noise_buf, step_size, leakage, err)
		
			scaling = 2^-(obj.filter_params.num_coef_bits+obj.filter_params.num_data_bits-2); % Not sure where the -2 factor comes from. You can tune it to converge faster/slower.
		
		    % Compute L2 Norm
            l2norm = 0;
            for ii = 1:length(noise_buf)
                l2norm = l2norm + noise_buf(ii) * noise_buf(ii);
            end
			l2norm = l2norm .* 2^-(obj.filter_params.num_data_bits); % Put 2x data_width result back to 1x data_width
			
			l2norm_inv = 1 / l2norm; % Invert L2 norm (division of 1x data_width number of bits)
			l2norm_inv = l2norm_inv .* 2^(obj.filter_params.num_data_bits); % Put 2x data_width result back to 1x data_width
            
			noise_buf_idx = length(noise_buf);
			for ii = 1:length(coefs)				
				coefs(ii) = 2^-(obj.filter_params.num_coef_bits-1)*((2^(obj.filter_params.num_coef_bits-1)-1)-floor(leakage*step_size*2^-((obj.filter_params.num_coef_bits-3))))*coefs(ii) + floor(scaling * step_size * err * noise_buf(noise_buf_idx)) * l2norm_inv; % This node is 2x data_width + coef_width
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