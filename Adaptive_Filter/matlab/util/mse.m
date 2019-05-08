function result = mse(desired, actual)
% Function calculates the Mean Square Error (MSE) between two signals

	N = length(desired);

	result = 1/N .* sum((desired-actual).^2);
	
end