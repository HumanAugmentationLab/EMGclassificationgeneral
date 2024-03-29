function [accuracy] = classification_accuracy(selectedclassifier, predictors, response, cpart)
%findes the classification accuracy with a given set of training data, a
%classifier, and the predictor names. Returns the accuracy as a decimal.
%   Detailed explanation goes here

for cl = 1:length(selectedclassifier)
    switch selectedclassifier{cl}
        case 'linSVMmuli'
            % Linear SVM for more than 2 outputs
            trainedClassifier = fitcecoc(predictors,response);
    end
end

partitionedModel = crossval(trainedClassifier,'CVPartition',cpart);
[validationPredictions] = kfoldPredict(partitionedModel);
     

% Cross validation output
responsearray = table2array(response);
validationAccuracy = sum(responsearray==validationPredictions)./length(responsearray); %can I replace traindata with something I am already passing in or do I have to pass in train data too?
accuracy = validationAccuracy;
end

