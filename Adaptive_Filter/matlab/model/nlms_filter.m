
classdef nlms_filter < adaptive_filter

	methods (Access = public)
		function obj = nlms_filter()
			obj = obj@adaptive_filter();
		end	
	end
	
	methods (Access = protected)
		function coefs = update_coefs(obj, coefs, noise_buf, step_size, leakage, err)
		
            % Compute L2 Norm
            l2norm = 0;
            for ii = 1:length(noise_buf)
                l2norm = l2norm + noise_buf(ii) * noise_buf(ii);
            end
            
			noise_buf_idx = length(noise_buf);
			for ii = 1:length(coefs)
				coefs(ii) = coefs(ii) + step_size * err * noise_buf(noise_buf_idx) / l2norm;
				noise_buf_idx = noise_buf_idx - 1;
			end
			
		end
		
	end

end