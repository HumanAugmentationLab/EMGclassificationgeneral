%% 
% Function iterates through each feature and creates a correlation matrix for 
% all channels for this given feature.Then, takes the mean of correlation 
% coefficients across features for each channel. The output is a correlation
% matrix of this mean of correlation coefficients. 

% If 2 channels are highly correlated, we can see what happens to our
% classification accuracy when we remove one of them. Theoretically, our
% classification accuracy should not decrease significantly/ should stay
% about the same. This helps us decrease the computational cost. 
% 
% Rishita Sarin (07/14/2020)
%%

ch_corr(includedfeatures, includedchannels, traindata) %calls function below

function [meancorrmat] = ch_corr(includedfeatures, includedchannels, traindata)
for n = 1:length(includedfeatures) %iterate through features
    idx_feat = contains(traindata.Properties.VariableNames, includedfeatures(n)); %find index where the feature exists in traindata
    predictorNames = traindata.Properties.VariableNames(idx_feat); %for each feature, take all channels
    predictors = traindata(:,predictorNames);  %extract traindata for all channels with feature n
    corr_mat(:,:,n) = corr(double(table2array(predictors))); %correlation matrix (size = #channels x #channels x #features that we have looped through)
end
meancorrmat = mean(corr_mat,3); %mean of corr coeffs for all channels across features measured (size = #channels x #channels x 1)
imagesc(meancorrmat) %visual of mean correlation matrix
title('Mean correlation matrix of all Channels (SEEDS)');
xlabel('channels');
ylabel('channels');
c = colorbar;
caxis([-1 1]); %limits for colorbar
c.Label.String = 'Correlation Coefficient';
xticks(1:length(includedchannels));
xticklabels(includedchannels);% Label x axis
yticks(1:length(includedchannels));
yticklabels(includedchannels);% Label y axis
end


