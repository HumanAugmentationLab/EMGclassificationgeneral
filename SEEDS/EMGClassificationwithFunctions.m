%EMG Classification using functions 
%7/20/2020

includedfeatures = {'mav', 'var', 'rms', 'zeros', 'aac'};
includedchannels = [1:6:126 127:134];
selectedclassifier = {'linSVMmuli'};
response = traindata(:,'labels'); %labels

predictorNames = select_data(traindata, includedfeatures, includedchannels);
predictors = traindata(:,predictorNames);

c = classification_accuracy(selectedclassifier, predictors, response, traindata);
fprintf('\nc = %.2f%%\n', validationAccuracy*100); %print accuracy

