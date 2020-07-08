function [L] = lscale(X)
%L-Scale calculations
%   L-scale is a calculation based on l-moments (second l-moment). Useful
%   because it is less effected by outliers then other data features. In
%   this code data can be a two dimensional matrix where each row is the
%   data of each trial. 

[rows, col] = size(X);
X = sort(X); %sorts elements in each column from lowest to highest
b0 = mean(X); %creates a vector holding the mean of each column/trial
b = zeros(col, 1);
l = zeros(1, col);

Num = 1:rows-1; %array filled with integers from 1 to one less then the amount of rows/data points
Den = rows-1;

for n = 1:col
    b(n) = 1/rows * sum((Num/Den .* X(2:rows,n)')); %
end 

tB = [b0' b]';
Coeff = [-1; 2]; %changed this from LegendreShiftPoly(i)


for i = 1:col
    l(i) = sum((Coeff.*tB(:,i)));
end 
L = l

end