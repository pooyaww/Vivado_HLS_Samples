
classdef rls_filter < adaptive_filter

	methods (Access = public)
		function obj = rls_filter()
			obj = obj@adaptive_filter();
		end	
	end
	
	methods (Access = protected)
		function coefs = update_coefs(obj, coefs, noise_buf, step_size, P, err)
		
		
			% x (noise_buf) is a column vector
			% Px is a matrix of size length(coefs) x length(coefs)
			% Lambda is a scaler			
		
			lambda = 0.98;
			
			noise_buf = noise_buf';
		
			% Compute g
			g = P*noise_buf / (lambda + noise_buf' * P * noise_buf); % Column vector
			
			% Compute new coefs
			coefs = coefs + err * g';
			
			% Compute new auto-covariance matrix
			P = 1/lambda * P - g*noise_buf'*1/lambda*P;
			
		end
		
	end

end

