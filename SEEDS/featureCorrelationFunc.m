%% 
% Function makes a correlation matrix of all features for each channel.
% Then, takes the mean of correlation coefficients across channels for each
% feature. The output is a correlation matrix of this mean of correlation
% coefficients. 

% If 2 features are highly correlated, we can see what happens to our
% classification accuracy when we remove one of them. Theoretically, our
% classification accuracy should not decrease significantly/ should stay
% about the same. This helps us decrease the computational cost. 
% 
% Rishita Sarin (07/14/2020)
%%

%feat_corr(includedchannels, includedfeatures, traindata) %calls function below

function [meancorrmat] = featureCorrelationFunc(includedchannels, traindata)

    %find all channels and name them
    names_ch = cellstr([repmat('_ch',length(includedchannels),1)  num2str(includedchannels') repmat('_',length(includedchannels),1) ]); 
    names_ch = strrep(names_ch,' ','');%remove spaces in single digit channel names (ch_ 1 --> ch_1)

    for n = 1:length(includedchannels) %iterate through channels
        idx_ch = contains(traindata.Properties.VariableNames,names_ch(n)); %find index where the channel exists in traindata
        predictorNames = traindata.Properties.VariableNames(idx_ch); %for each channel, take all features
        predictors = traindata(:,predictorNames); %extract data of predictorNames from traindata
        corr_mat(:,:,n) = corr(double(table2array(predictors))); %correlation matrix (size = #features x #features x #channels that we have looped through)
    end
    meancorrmat = mean(corr_mat,3); %mean of corr coeffs for all features across channels measured (size = #features x #features x 1)

end