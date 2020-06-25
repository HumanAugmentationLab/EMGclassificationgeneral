function [L] = lscale(data)
%L-Scale calculations
%   L-scale is a calculation based on l-moments (second l-moment). Useful
%   because it is less effected by outliers then other data features. In
%   this code data can be a two dimensional matrix where each row is the
%   data of each trial. 

[rows, col] = size(data);
X = sort(data, 2); %sorts data points from lowest to highest along the rows 
b0 = mean(data, 2);
b = zeros(rows, 1)
l = zeros(1, rows)

Num = 1:col-1
Den = col-1

for n = 1:rows
    b(n) = 1/col * sum((Num/Den .* X(n,2:col))); %SWM changed this from data to X
end 

tB = [b0 b]'
Coeff = [-1; 2] %changed this from LegendreShiftPoly(i)

for i = 1:rows
    l(i) = sum((Coeff.*tB(:,1)),"all");
end 
L = l

end

