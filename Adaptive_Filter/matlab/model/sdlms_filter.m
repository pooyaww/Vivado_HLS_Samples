
% Sign-Data LMS from http://www.mathworks.com/help/dsp/ref/dsp.lmsfilter-class.html
% or http://zone.ni.com/reference/en-XX/help/372357A-01/lvaftconcepts/aft_lms_algorithms/
%
% Compared to normal LMS, sign algorithms only requires 1 multiplication (if step size is
% a power of 2, it can be reduced to zero multiplications. However, it's slower to
% converge and has more steady state error

classdef sdlms_filter < adaptive_filter

	methods (Access = public)
		function obj = sdlms_filter()
			obj = obj@adaptive_filter();
		end	
	end
	
	methods (Access = protected)
		function coefs = update_coefs(obj, coefs, noise_buf, step_size, leakage, err)
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
				coefs(ii) = coefs(ii) + step_size * err * noise_buf_sgn;
				noise_buf_idx = noise_buf_idx - 1;
			end
			
		end
		
	end

end

