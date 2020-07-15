%% 
% This code iterates through each feature and creates a correlation matrix for 
% all channels for any given feature. 
% 
% Rishita Sarin (07/14/2020)
%%

ch_corr(includedfeatures, traindata)

function [correlation_matrix] = ch_corr(includedfeatures, traindata)
for n = 1:length(includedfeatures)
    idx_feat = contains(traindata.Properties.VariableNames, includedfeatures(n));
    predictorNames = traindata.Properties.VariableNames(idx_feat);
    %extract traindata for all channels feature n
    predictors = traindata(:,predictorNames);
    %print correlation matrix
    correlation_matrix = corr(table2array(predictors));
    n
    imagesc(correlation_matrix)
    colorbar
end
end


