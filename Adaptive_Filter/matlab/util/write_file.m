function write_file(data, fname)
% Function writes data to a file called fname, one sample per column
			
	fid = fopen(fname, 'w');
	for ii = 1:length(data)
		fprintf(fid, '%d\n', data(ii));
	end
	fclose(fid);
	
end