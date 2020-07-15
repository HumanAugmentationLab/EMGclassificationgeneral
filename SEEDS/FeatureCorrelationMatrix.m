%Correlation Matrix for EMG Features
%  7/14/2020

[row, col] = size(traindata);

%traindata(1:10, 3:10)
feature_matrix = traindata{:,3:end}; %putting traindata numbers into matrix
%this seems to be roudind the tabel numbers and i dont want that

correlation_matrix = corr(feature_matrix);

imagesc(correlation_matrix)