function tb_run_test(obj, params, d, noise, WAIT_ON_USER)
    
    % Test setup
    obj.set_uut_params(params);
    obj.set_desired(d);
    obj.set_noise(noise);
    
    % Run test and wait
    obj.run_all();
	if (WAIT_ON_USER)
		input('press return key to continue...');
	end
    
    % Cleanup
    close all;
    
end