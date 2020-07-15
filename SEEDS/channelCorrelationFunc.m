%% 
% This code iterates through each feature and creates a correlation matrix for 
% all channels for any given feature. 
% 
% Rishita Sarin (07/14/2020)
%%

ch_corr(includedfeatures, traindata)

function [meancorrmat] = ch_corr(includedfeatures, traindata)
for n = 1:length(includedfeatures)
    idx_feat = contains(traindata.Properties.VariableNames, includedfeatures(n));
    predictorNames = traindata.Properties.VariableNames(idx_feat);
    %extract traindata for all channels feature n
    predictors = traindata(:,predictorNames);
    %print correlation matrix
    corr_mat(:,:,n) = corr(double(table2array(predictors)));
    meancorrmat = mean(corr_mat,3)
    imagesc(meancorrmat)
    title('Mean correlation matrix of all Channels')
    xlabel('channels')
    ylabel('channels')
    c = colorbar
    c.Label.String = 'Correlation Coefficient'
end
end


