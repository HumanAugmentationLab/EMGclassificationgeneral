% Create correlation matrices for each subject and group
%  Correlations are channel x channel (averaged across selected features)

clear

%dir_input = 'C:\Users\rsarin\Google Drive\ArmEMG\Data\SEEDS\FeaturesSubj\';
dir_input = 'C:\Users\saman\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\';
fname_input = '-allfeatures'; %'-SEEDSfeatures'; %Tag for file name (follows subject name)
includedspeeds={'both','slow','fast'}; %cell array of all speeds
sp = 1; %speed we want to examine
includedsubjectnumbers = [1:9]; %total number of subjects we will examine. This is a temporary fix. I want Matlab to calculate this.

%includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110t256', 'bp256t512'};
includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110t256', 'bp256t512',...
        'rms', 'iemg','mmav1','mpv','var', 'mav', 'aac', 'zeros', 'mfl', 'ssi', 'medianfreq', 'wamp',...
        'lscale', 'dfa', 'wl', 'm2', 'damv' 'dasdv', 'dvarv', 'ld', 'meanfreq', 'stdv', 'skew', 'kurt', 'mob'};

includedchannels = 1:126;% [1:126]; %1:134 for all channels, 127:134 for only monopolar EMG sensors

for s = 1:length(includedsubjectnumbers) %iterate through each subject  
    load(strcat(dir_input,'subj',num2str(includedsubjectnumbers(s),'%02.f'),fname_input,'_speed',includedspeeds{sp},'.mat'),'traindata') %load data for the subject
    predictorNames = select_data(traindata.Properties.VariableNames, includedfeatures, includedchannels); 
    corr_mat(:,:,s) = channelCorrelationFunc(includedfeatures, traindata(:,predictorNames)) ; %For each subject, call channelCorrelationFunc.m
    
    % Comment out below if you only want to make the average plot
    %figure %to ensure we don't delete our old figure each time the loop runs
    %plot_corr(corr_mat(:,:,s),includedchannels,'Mean Correlation Matrix for SEEDS Features', 'Channels', includedsubjectnumbers(s)); %input subject number if you want this in the title
end
meansubjcorrmat = mean(corr_mat,3); %mean of corr coeffs for all features across channels measured (size = #features x #features x 1)
figure
plot_corr(meansubjcorrmat,includedchannels,'Mean Correlation Matrix For Channels', 'Channels')