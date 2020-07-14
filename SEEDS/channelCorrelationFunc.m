%% 
% This code iterates through each feature and creates a correlation matrix for 
% all channels for any given feature. 
% 
% Rishita Sarin (07/14/2020)

ch_corr(includedfeatures, traindata)
%%
function [correlation_matrix] = ch_corr(feature_list, traindata)
for n = 1:length(feature_list);
    feature_list(n);
    %extract traindata for all channels feature n
    all_channels_n = traindata(n);
    %print correlation matrix
    correlation_matrix = corr(all_channels_n);  
end
end