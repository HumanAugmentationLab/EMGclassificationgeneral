function [HMob] = Mobility(X)
% Hjorth's Mobility Parameter
HMob = sqrt((var(diff(X)))./(var(X)));
end