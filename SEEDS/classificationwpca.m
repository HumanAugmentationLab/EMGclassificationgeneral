%Classification of PCA 

includedfeatures = {'mav', 'var', 'rms', 'zeros', 'aac'};
includedchannels = [1:6:126 127:134];
selectedclassifier = {'linSVMmuli'};
response = traindata(:,'labels'); %labels

variablenames = traindata.Properties.VariableNames;
predictorNames = select_data(variablenames, includedfeatures, includedchannels);
predictors = traindata(:,predictorNames);

predictors_array = table2array(predictors);
coeff = pca(predictors_array);
princ_coeff = coeff(:,1:3); %only use first 5 principal component coefficents 
reduced_data = predictors_array*princ_coeff;

reduced_data_table = array2table(reduced_data);


kval = 9;
% Predictors are features
cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation

c = classification_accuracy(selectedclassifier, reduced_data_table, response, cpart);
fprintf('\nc = %.2f%%\n', c*100); %print accuracy