% lmom by Kobus N. Bekker, 14-09-2004
% Based on calculation of probability weighted moments and the coefficient
% of the shifted Legendre polynomial.

% Given nonnegative integer nL, compute the 
% nL l-moments for given data vector X. 
% Return the l-moments as vector L.

function [L] = lscale(X)

[rows cols] = size(X);
if cols == 1 X = X'; end
n = length(X);
X = sort(X); %sorts data points from lowest to highest
b = zeros(1,1);
l = zeros(1,1);
b0 = mean(X);


Num = prod(repmat(2:n,1,1)-repmat([1:1]',1,n-1),1);
Den = prod(repmat(n,1,1) - [1:1]);
b(1) = 1/n * sum( Num/Den .* X(2:n) );


tB = [b0 b]';
B = tB(length(tB):-1:1);

Coeff = [2; -1]; %changed this from LegendreShiftPoly(i)
l(1) = sum((Coeff.*B),1);


L = [b0 l];


%compare l-scale to absolute deviation and standard deviation (do that for
%3 or 4 examples with different out lires 
%sum(abs(X-mean(X)))./n %absolute deviation

%LegendreShiftPoly(i) %replace with multipy by two and subtract the mean

