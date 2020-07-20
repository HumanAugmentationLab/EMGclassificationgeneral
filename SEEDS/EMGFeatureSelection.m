% Feature Selection by adding features and checking accuracy 


all_features = ;

accuracy = 0;
kept_features = []; %empty list to hold the index of features to keep 
%input includedfeatures(kept_features) to a select data function

selectedclassifier = {'linSVMmuli'};


response = traindata(:,'labels'); %labels

%add features
for n = 1:length(all_features)
    kept_features = [kept_features n];
    predictorNames = select_data(kept_features);
    predictors = traindata(:,predictorNames);
    c =  accuracy(selectedclassifier, predictors, response);%run classification code with kept features and return accuracy:
    %select data using includedfeatures(kept_features) TODO: writt a select
    %data function 
    %run a classification function that uses selected data and outputs a
    %classification accuracy 
    if c > accuracy
        accuracy = c ; 
    else 
        kept_features(end) = []; %removes last value
        %remove n from kept features
    end
end
        
        
%subtrace features in verse order
for n = length(kept_features):-1:1
    
    
end 

%print included features
fprintf('\naccuracy = %.2f%%\n', validationAccuracy*100); %print accuracy

    

    