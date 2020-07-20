function [accuracy] = classification_accuracy(traindata, selectedclassifier, predictorNames)
%findes the classification accuracy with a given set of training data, a
%classifier, and the predictor names. Returns the accuracy as a decimal.
%   Detailed explanation goes here

%add these to inputs later
kval = 9;

% Predictors are features
predictors = traindata(:,predictorNames); %This is the X
response = traindata(:,'labels'); %labels
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
validationAccuracy = sum(traindata.labels==validationPredictions)./length(traindata.labels);
accuracy = validationAccuracy;
end

