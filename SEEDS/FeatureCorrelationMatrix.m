%Correlation Matrix for EMG Features
%  7/14/2020

[row, col] = size(traindata);

feature_matrix = traindata{1:row,3:col}; %putting traindata numbers into matrix
%this seems to be roudind the tabel numbers and i dont want that

correlation_matrix = corr(feature_matrix);
