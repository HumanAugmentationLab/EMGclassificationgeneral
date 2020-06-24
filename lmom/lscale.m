function [L] = lscale(data)
%L-Scale calculations
%   Detailed explanation goes here

[rows, col] = size(data);
X = sort(data, 2); %sorts data points from lowest to highest along the rows 
b0 = mean(data, 2);
b = zeros(rows, 1)
l = zeros(1, rows)

Num = 1:col-1
Den = col-1

for n = 1:rows
    b(n) = 1/col * sum((Num/Den .* data(n,2:col)));
end 

tB = [b0 b]'
Coeff = [-1; 2] %changed this from LegendreShiftPoly(i)

for i = 1:rows
    l(i) = sum((Coeff.*tB(:,1)),"all");
end 
L = l

end

