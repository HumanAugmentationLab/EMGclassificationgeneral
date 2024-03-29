% Create correlation matrices for each subject and group
%  Correlations are feature x feature (averaged across channels)
clear

%dir_input = 'C:\Users\rsarin\Google Drive\ArmEMG\Data\SEEDS\FeaturesSubj\';
dir_input = 'C:\Users\saman\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\';
%dir_input = 'C:\Users\msivanandan\Google Drive\ArmEMG\Data\SEEDS\FeaturesSubj\';

%fname_input = '-SEEDSfeatures'; %Tag for file name (follows subject name)
%includedfeatures = {'mav', 'var', 'rms', 'zeros', 'aac'};

fname_input = '-allfeatures';
% includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110t256', 'bp256t512',...
%         'rms', 'iemg','mmav1','mpv','var', 'mav', 'aac', 'zeros', 'mfl', 'ssi', 'medianfreq', 'wamp',...
%         'lscale', 'dfa', 'wl', 'm2', 'damv' 'dasdv', 'dvarv', 'msr', 'ld', 'meanfreq', 'stdv', 'skew', 'kurt', 'mob'};

% Note: MSR is complex. We need to fix this in code and rerun for subjects
includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110t256', 'bp256t512',...
        'rms', 'iemg','mmav1','mpv','var', 'mav', 'aac', 'zeros', 'mfl', 'ssi', 'medianfreq', 'wamp',...
        'lscale', 'dfa', 'wl', 'm2', 'damv' 'dasdv', 'dvarv', 'ld', 'meanfreq', 'stdv', 'skew', 'kurt', 'mob'};


%includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110t256', 'bp256t512'};
includedspeeds={'both','slow','fast'}; %cell array of all speeds
sp = 1; %speed we want to examine
includedsubjectnumbers = [1:9]; %total number of subjects we will examine. This is a temporary fix. I want Matlab to calculate this.
includedchannels = [1:126]; %1:134 for all channels, 127:134 for only monopolar EMG sensors


for s = 1:length(includedsubjectnumbers) %iterate through each subject  
    load(strcat(dir_input,'subj',num2str(includedsubjectnumbers(s),'%02.f'),fname_input,'_speed',includedspeeds{sp},'.mat'),'traindata') %load data for the subject
    predictorNames = select_data(traindata.Properties.VariableNames, includedfeatures, includedchannels);    
    corr_mat(:,:,s) = featureCorrelationFunc(includedchannels, traindata(:,predictorNames)); %For each subject, call featureCorrelationFunc.m
    
    % Comment out below if you only want to make the average plot
    %plot_corr(corr_mat(:,:,s),includedfeatures, 'Mean Correlation Matrix For All Features', 'FEATURES', includedsubjectnumbers(s)); %input subject number if you want this in the title
end
meansubjcorrmat = mean(corr_mat,3); %mean of corr coeffs for all features across channels measured (size = #features x #features x 1)

plot_corr(meansubjcorrmat,includedfeatures, 'Mean Correlation Matrix For All Features', 'FEATURES')