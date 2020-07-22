%%
% For each subject data, call featureCorrelationFunc
%(which averages the channels for each feature, to give us a feature x feature correlation matrix).
% Then, I store the correlation matrix for each subject data and take the average across all the subjects
% to give us a feature x feature correlation matrix.  
%%
includedsubjects = {} %set includedsubjects to an empty cell array
for s=1:length(subjectnumbers) %Loop through all subjects
    subj_data = load(strcat(dir_input,'subj',num2str(subjectnumbers(s),'%02.f'),fname_input,'.mat'));
    includedsubjects = {includedsubjects subj_data}; %make cell array of all the subject data
end 
for n = 1:length(includedsubjects) % Loop through all subjects 
    feat_corr(includedchannels, includedfeatures, traindata) %For each subject, call featureCorrelationFunc.m
    corr_mat(:,:,n) = meancorrmat;
end
meansubjcorrmat = mean(corr_mat,3);
imagesc(meansubjcorrmat) %visual of mean subject correlation matrix 
title('Mean correlation matrix of SEEDS Features for includedsubjects');
xlabel('FEATURES');
xticks([1 2 3 4 5]); %temporary fix for #features - ideally would like to have name of feature as a tick. 
yticks([1 2 3 4 5]); %same as x tick
ylabel('FEATURES');
c = colorbar;
caxis([-1 1]); %limits for colorbar
c.Label.String = 'Correlation Coefficient';
xticks(1:length(includedfeatures));
xticklabels(includedfeatures);% Label x axis
yticks(1:length(includedfeatures));
yticklabels(includedfeatures);% Label y axis
    