function [predictorNames] = select_data(variablenames, includedfeatures, includedchannels)
%Select Data: input a list of the indices of features to included in the classification
%and return a matrix that only includes the data of the included features
%   Detailed explanation goes here

%make includedchannels optional to add

    if isempty(includedchannels)
        % Include all features
        idx_feat = contains(variablenames,'FEAT_'); % Find all of ones that start with FEAT_
        idx_selfeat = contains(variablenames,strcat('_',includedfeatures));
        predictorNames = variablenames(idx_selfeat & idx_feat); %column names that are FEAT and are the channels we want to include
    else 
        idx_feat = contains(variablenames,'FEAT_'); % Find all of ones that start with FEAT_
        names_ch = cellstr([repmat('_ch',length(includedchannels),1)  num2str(includedchannels') repmat('_',length(includedchannels),1) ]); 
        names_ch = strrep(names_ch,' ',''); % Remove spaces
        idx_ch = contains(variablenames,names_ch);
        idx_selfeat = contains(variablenames,strcat('_',includedfeatures));
        predictorNames = variablenames(idx_ch & idx_feat & idx_selfeat); %column names that are FEAT and are the channels we want to include
    end
end