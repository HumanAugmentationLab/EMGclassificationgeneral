%Classification of PCA 

includedfeatures = {'mav', 'var', 'rms', 'zeros', 'aac'};
includedchannels = [1:6:126 127:134];
selectedclassifier = {'linSVMmuli'};
response = traindata(:,'labels'); %labels

variablenames = traindata.Properties.VariableNames;
predictorNames = select_data(variablenames, includedfeatures, includedchannels);
predictors = traindata(:,predictorNames);

predictors_array = table2array(predictors);
pcadata = pca(predictors_array);
pcatable = array2table(pcadata);


kval = 9;
% Predictors are features
cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation

c = classification_accuracy(selectedclassifier, pcatable, response, cpart);
fprintf('\nc = %.2f%%\n', c*100); %print accuracy