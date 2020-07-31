function [HMob] = Mobility(mydata, mytimes)
% Hjorth's Mobility Parameter
vardxdt = var(gradient(mydata)./gradient(mytimes)');
HMob = (sqrt(vardxdt./(var(mydata))))';
end