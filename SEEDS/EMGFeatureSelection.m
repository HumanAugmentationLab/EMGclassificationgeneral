% Feature Selection by adding features and checking accuracy 

all_features = ; %need a full list of the features and channels

classification_accuracy = 0;
kept_features = []; %empty list to hold the features to keep 

%add features
for n:length(all_features)
    kept_features = [kept_features n];
    c =  ;%run classification code with kept features and return accuracy
    if c > classification_accuracy
        classification_accuracy = c ; 
    else 
        %remove n from kept features
        
        
%subtrace features in verse order
for n:length(kept_features)
    

    