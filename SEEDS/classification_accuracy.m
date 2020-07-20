function [accuracy] = classification_accuracy(selectedclassifier, predictors, response, traindata)
%findes the classification accuracy with a given set of training data, a
%classifier, and the predictor names. Returns the accuracy as a decimal.
%   Detailed explanation goes here

%add these to inputs later
kval = 9;

% Predictors are features
cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation


for cl = 1:length(selectedclassifier)
    switch selectedclassifier{cl}
        case 'linSVMmuli'
            % Linear SVM for more than 2 outputs
            trainedClassifier = fitcecoc(predictors,response);
    end
end

partitionedModel = crossval(trainedClassifier,'CVPartition',cpart);
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);
     

% Cross validation output
validationAccuracy = sum(traindata.labels==validationPredictions)./length(traindata.labels); %can I replace traindata with something I am already passing in or do I have to pass in train data too?
accuracy = validationAccuracy;
end

