% make correlation matrix of features for each channel and then average 
%the correlation matrices.

%iterate through channels
    %for each channel, take all features
    %correlation matrix of features for each channel (total 134 correlation
    %matrices)

 temp = traindata(:,3:7);
[row, col] = size(temp);
feature_matrix = traindata{row,col} %putting traindata numbers into matrix
%this seems to be roudind the tabel numbers and i dont want that
correlation_matrix = corr(feature_matrix);
