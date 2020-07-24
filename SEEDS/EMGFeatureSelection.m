% Feature Selection by adding features and checking accuracy 

all_features = traindata.Properties.VariableNames;

accuracy = 0;
added_features = {}; %empty of features kept in the addition phase
kept_features = {}; %empty list of features kept after addition and subtraction 
%input includedfeatures(kept_features) to a select data function

includedfeatures = {'mav', 'var', 'rms', 'zeros', 'aac'};
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
    c =  classification_accuracy(selectedclassifier, predictors, response, cpart);%run classification code with kept features and return accuracy:
    %select data using includedfeatures(kept_features) TODO: writt a select
    %data function 
    %run a classification function that uses selected data and outputs a
    %classification accuracy 
    if c > accuracy
        accuracy = c ; 
    else 
        added_features(end) = []; %removes last value
        %remove n from kept features
    end
end
        
kept_features = added_features  

%subtrace features in verse order
for n = length(added_features):-1:1
   kept_features{n} = [] %removes feature n
   predictorNames = select_data(all_features, kept_features, includedchannels);
   predictors = traindata(:,predictorNames);
   c =  classification_accuracy(selectedclassifier, predictors, response, cpart)
   if c < accuracy
        kept_features{n} = added_features{n} 
   elseif c > accuracy 
       accuracy = c; %if accuracy increased reset accuracy and leave feature off list 
   end
end 

%print included features
kept_features
fprintf('\naccuracy = %.2f%%\n', c*100); %print accuracy

    

    