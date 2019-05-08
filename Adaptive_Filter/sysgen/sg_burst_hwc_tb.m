function filter_output = sg_burst_hwc_tb(noise, signal_with_noise, NUM_CYCLES)

	% Constants
	max_burst  = 8192;
	
	% Setup input signals
	noise2 = repmat(noise', 60, 1);
	noise3 = noise2(:);
	noise4 = [zeros(1, 130) noise3(1:end-129)'];
	testdata_noise_x0 = noise4;
	
	signal_with_noise2 = repmat(signal_with_noise', 60, 1);
	signal_with_noise3 = signal_with_noise2(:);
	signal_with_noise4 = [zeros(1, 130) signal_with_noise3(1:end-129)'];
	testdata_signal_with_noise = signal_with_noise4;
	
	testdata_rst = [ones(1,10), zeros(1, 3932160-10)];
	
	% Setup stuff for HWC
	write_periods        = [1];
	write_pointers       = zeros(size(write_periods));
	cycles_to_next_write = zeros(size(write_periods));
	read_periods         = [1];
	read_pointers        = zeros(size(read_periods));
	cycles_to_next_read  = zeros(size(read_periods));
	result_ap_done       = zeros(1, 3932160);
	result_filter_out    = zeros(1, 3932160);

	% Run the HWC, one burst at a time
	h = Hwcosim('netlist/burst_hwc.hwc');
	open(h); 
	for i = 0:max_burst:(NUM_CYCLES-1)
		burstsize = min(max_burst, NUM_CYCLES-i);
		num_burst_writes = ceil((burstsize + cycles_to_next_write) ./ write_periods);
		cycles_to_next_write = burstsize + cycles_to_next_write - num_burst_writes .* write_periods;
		num_burst_reads = floor((burstsize + cycles_to_next_read) ./ read_periods);
		cycles_to_next_read = burstsize + cycles_to_next_read - num_burst_reads .* read_periods;
		if num_burst_writes(1) > 0
		  h('noise_x0')          = testdata_noise_x0(write_pointers(1)+(1:num_burst_writes(1)));
		  h('rst')               = testdata_rst(write_pointers(1)+(1:num_burst_writes(1)));
		  h('signal_with_noise') = testdata_signal_with_noise(write_pointers(1)+(1:num_burst_writes(1)));
		end
		write_pointers = write_pointers + num_burst_writes;
		run(h, burstsize);
		if num_burst_reads(1) > 0
		  result_ap_done(read_pointers(1)+(1:num_burst_reads(1))) = h('ap_done', num_burst_reads(1));
		  result_filter_out(read_pointers(1)+(1:num_burst_reads(1))) = h('filter_out', num_burst_reads(1));
		end
		read_pointers = read_pointers + num_burst_reads;
	end 
	release(h);

	result_ap_done    = result_ap_done(1:read_pointers(1));
	result_filter_out = result_filter_out(1:read_pointers(1));
	disp('Simulation successful: netlist/burst_hwc.') ;

	% Construct a vector consisting only of samples that coincide with assertion of ap_done
	jj = 1;
	for ii = 1:length(result_filter_out)
		if (result_ap_done(ii))
			filter_output(jj) = result_filter_out(ii);
			jj = jj + 1;
		end
	end
	
	filter_output = filter_output;

end