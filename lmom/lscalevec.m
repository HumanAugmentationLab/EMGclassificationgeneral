function [L] = lscalevec(data)
X = sort(data); %sorts data points from lowest to highest along the rows 
rows = size(X,1);
scaler = (1:(rows-1))'./(rows-1);
b =  1/rows * sum(scaler.*X(2:end,:));
L = 2.*b - mean(X);