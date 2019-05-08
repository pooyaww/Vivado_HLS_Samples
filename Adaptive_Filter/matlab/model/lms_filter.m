
classdef lms_filter < adaptive_filter

	methods (Access = public)
		function obj = lms_filter()
			obj = obj@adaptive_filter();
		end	
	end
	
	methods (Access = protected)
		function coefs = update_coefs(obj, coefs, noise_buf, step_size, leakage, err)
		
			noise_buf_idx = length(noise_buf);
			for ii = 1:length(coefs)
				coefs(ii) = coefs(ii) + step_size * err * noise_buf(noise_buf_idx);
				noise_buf_idx = noise_buf_idx - 1;
			end
			
		end
		
	end

end

