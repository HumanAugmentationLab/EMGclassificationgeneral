% Feature Selection by adding features and checking accuracy 

dir_input = 'C:\Users\dketchum\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Declan's 
fname_input = '-allfeatures'; %Tag for file name (follows subject name)

includedspeeds={'both','slow','fast'};%
sp = 2;
subjectnumbers = 2;
s=1; %This is here to make loops later
load(strcat(dir_input,'subj',num2str(subjectnumbers(s),'%02.f'),fname_input,'_speed',includedspeeds{sp},'.mat'))


all_features = traindata.Properties.VariableNames;

accuracy = 0;
added_features = {}; %empty of features kept in the addition phase
%input includedfeatures(kept_features) to a select data function

includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110t256', 'bp256t512',...
        'rms', 'iemg','mmav1','mpv','var', 'mav', 'zeros', 'mfl', 'ssi', 'medianfreq', 'wamp',...
        'lscale', 'dfa', 'wl', 'm2', 'damv' 'dasdv', 'dvarv', 'msr', 'ld', 'meanfreq', 'stdv', 'skew', 'kurt',...
         'np'};
%includedfeatures = {'rms', 'mav', 'var', 'zeros', 'aac'}; %SEEDS features
includedchannels = [1:6:126 127:134];
selectedclassifier = {'linSVMmuli'};
response = traindata(:,'labels'); %labels

kval = 9;
% Predictors are features
cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation


%add features
for n = 1:length(includedfeatures)
    added_features{end+1} = includedfeatures{n};
    predictorNames = select_data(all_features, added_features, includedchannels);
    predictors = traindata(:,predictorNames);
    c =  classification_accuracy(selectedclassifier, predictors, response, cpart);%run classification code with kept features and return accuracy
    if c > accuracy
        accuracy = c;
    else 
        added_features(end) = []; %removes last value
        %remove n from kept features
    end
end
        
kept_features = added_features;

%subtrace features in verse order
for n = length(added_features):-1:1
   kept_features(n) = []; %removes feature n
   if isempty(kept_features)
       c = 0;
   else 
     predictorNames = select_data(all_features, kept_features, includedchannels);
     predictors = traindata(:,predictorNames);
     c =  classification_accuracy(selectedclassifier, predictors, response, cpart);
   end 
   
   if c < accuracy
        kept_features{n} = added_features{n};
   else 
       accuracy = c; %if accuracy increased reset accuracy and leave feature off list 
   end
end 

%print included features and best accuracy 
kept_features
fprintf('\naccuracy = %.2f%%\n', c*100); %print accuracy