
classdef tb_lib_fxd < tb_lib
	
	methods (Access = public)
		
		function obj = tb_lib_fxd(do_generate_plots, do_write_files, desired_fname, noise_fname, output_fname, uut)
            obj = obj@tb_lib(do_generate_plots, do_write_files, desired_fname, noise_fname, output_fname, uut);
        end
		
		function set_desired(obj, desired)
			obj.desired = round(desired .* 2^(obj.uut.get_num_data_bits()-1));
		end
		
		function desired = get_desired(obj)
			desired = obj.desired .* 2^-(obj.uut.get_num_data_bits()-1);
		end
		
		function set_noise(obj, noise)
			obj.noise = round(noise .* 2^(obj.uut.get_num_data_bits()-1));
		end
		
		function noise = get_noise(obj)
			noise = obj.noise .* 2^-(obj.uut.get_num_data_bits()-1);
		end
		
		function signal_with_noise = get_signal_with_noise(obj)
			signal_with_noise = obj.signal_with_noise .* 2^-(obj.uut.get_num_data_bits()-1);
		end
		
		function output = get_output(obj)
			output = obj.output .* 2^-(obj.uut.get_num_data_bits()-1);
        end
		
    end

end

