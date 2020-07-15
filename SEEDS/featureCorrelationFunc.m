%% 
% make correlation matrix of features for each channel and then average 
%the correlation matrices.
% 
% Rishita Sarin (07/14/2020)
%%

feat_corr(includedchannels, traindata)

function [correlation_matrix] = feat_corr(includedchannels, traindata)

%find all channels and name them
names_ch = cellstr([repmat('_ch',length(includedchannels),1)  num2str(includedchannels') repmat('_',length(includedchannels),1) ]); 
names_ch = strrep(names_ch,' ','');

for n = 1:length(includedchannels) %iterate through channels
    idx_ch = contains(traindata.Properties.VariableNames,names_ch(n)); 
    predictorNames = traindata.Properties.VariableNames(idx_ch); %for each channel, take all features
    predictors = traindata(:,predictorNames);
    correlation_matrix = corr(table2array(predictors));
    imagesc(correlation_matrix)  %correlation matrix of features for each ch
    colorbar
end
end