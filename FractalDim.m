function [FDim] = FractalDim(X, k)
% Fractal Dimension
N = length(X);
for i = 2:N/k
   y =  abs(X.*(i*k) - X.*((i-1)*k));
end
FDim = (sum(y)*((N-1)/(N)))/k;
end