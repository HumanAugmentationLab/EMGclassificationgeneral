%EMG Classification using functions 
%7/20/2020

%dir_input = 'C:\Users\dketchum\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Declan's 
dir_input = 'C:\Users\msivanandan\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Maya's

% fname_input = '-allfeatures'; %Tag for file name (follows subject name)
% fname_input = '-PARAMETERSWEEPfeaturesChA';
% fname_input = '-PARAMETERSWEEPfeaturesChB';
% fname_input = '-PARAMETERSWEEPfeaturesChC';
% fname_input = '-PARAMETERSWEEPfeaturesChD';
% fname_input = '-PARAMETERSWEEPfeaturesChE';
 fname_input = '-PARAMETERSWEEPfeaturesChF';


includedspeeds={'both','slow','fast'};%
sp = 1;
subjectnumbers = 3;
s=1; %This is here to make loops later
load(strcat(dir_input,'subj',num2str(subjectnumbers(s),'%02.f'),fname_input,'_speed',includedspeeds{sp},'.mat'))


includedfeatures = {'meanfreq', 'lscale', 'mmav1', 'mpv', 'stdv', 'damv', 'zeros', 'bp40t56'};
includedchannels = [];
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

