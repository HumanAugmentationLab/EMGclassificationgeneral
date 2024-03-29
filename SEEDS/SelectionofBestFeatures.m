%creating table of individual feature classification accuracies
%and a graph of how the accuracy changes as you add features

%dir_input = 'C:\Users\saman\Documents\MATLAB\EMGdata\FeaturesSubj\'; %Sam's 
%dir_input = 'C:\Users\dketchum\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Declan's 
dir_input = 'C:\Users\rsarin\Google Drive\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Rishita's
fname_input = '-allfeatures'; %Tag for file name (follows subject name)

includedspeeds={'both','slow','fast'};%
sp = 1;
subjectnumbers = 9;
s=1; %This is here to make loops later
load(strcat(dir_input,'subj',num2str(subjectnumbers(s),'%02.f'),fname_input,'_speed',includedspeeds{sp},'.mat'))

includedchannels = [1:6:126 127:134]; % [] for all, otherwise this is a vector of channel numbers
includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110t256', 'bp256t512',...
        'rms', 'iemg','mmav1','mpv','var', 'mav', 'zeros', 'mfl', 'ssi', 'medianfreq', 'wamp',...
        'lscale', 'dfa', 'wl', 'm2', 'damv' 'dasdv', 'dvarv', 'msr', 'ld', 'meanfreq', 'stdv', 'skew', 'kurt',...
         'np'};
%includedfeatures = {'mav', 'var', 'rms', 'zeros', 'aac'};

kval = 9;% %Choose number of folds.
dotrainandtest = false; % If running on test as well as train

selectedclassifier = {'linSVMmuli'};

traindata = splitvars(traindata); %split subvariables into independent variable to not anger the classifier.
variablenames = traindata.Properties.VariableNames;
response = traindata(:,'labels'); %labels
cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation

acc = {}; %cell array to hold accuracies 

for n = 1:length(includedfeatures)
    %find classification accuracy for each feature individually
    includedfeature = includedfeatures(n)
    predictorNames = select_data(variablenames, includedfeature, includedchannels);
    predictors = traindata(:,predictorNames);
    
    acc{n} = classification_accuracy(selectedclassifier, predictors, response, cpart)
end 

accuracy_table = table(includedfeatures', acc', 'VariableNames', {'Feature', 'Accuracy'})
sorted_table = sortrows(accuracy_table, 2, 'descend'); %sort the rows of the accuracy

%Create figure of accuracy as features get added 
sorted_features = table2array(sorted_table(:,1))';

included_features = [];
accuracy = [];
for n = 1:length(sorted_features)
    included_features = [included_features sorted_features(n)];
    predictorNames2 = select_data(variablenames, included_features, includedchannels);
    predictors = traindata(:,predictorNames2);
    
    accuracy(n) = classification_accuracy(selectedclassifier, predictors, response, cpart);
end 

idx_sorted_features = 1:length(sorted_features);
plot(idx_sorted_features, accuracy,'o')
text(idx_sorted_features, accuracy, included_features); %labels
H=findobj(gca,'Type','text');
set(H,'Rotation',60); % tilt
xlabel('Number of Features');
ylabel('Classification Accuracy');
title('Class Accuracy as Num Feat Increases');

%table based on the second column which holds the accuracies
%order features based on validation accuracy
%add one feature at a time and run classification. record classification in
%an array 
%plot the list of features in order agains the classifcation accuracy array

