%EMG Classification using functions 
%7/20/2020

dir_input = 'C:\Users\dketchum\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Declan's 
fname_input = '-allfeatures'; %Tag for file name (follows subject name)

includedspeeds={'both','slow','fast'};%
sp = 2;
subjectnumbers = 6;
s=1; %This is here to make loops later
load(strcat(dir_input,'subj',num2str(subjectnumbers(s),'%02.f'),fname_input,'_speed',includedspeeds{sp},'.mat'))


includedfeatures = {'mav', 'var', 'rms', 'zeros', 'aac'};
includedchannels = [1:6:126 127:134];
selectedclassifier = {'linSVMmuli'};
response = traindata(:,'labels'); %labels

variablenames = traindata.Properties.VariableNames;
predictorNames = select_data(variablenames, includedfeatures, includedchannels);
predictors = traindata(:,predictorNames);


kval = 9;
% Predictors are features
cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation

c = classification_accuracy(selectedclassifier, predictors, response, cpart);
fprintf('\nc = %.2f%%\n', c*100); %print accuracy

