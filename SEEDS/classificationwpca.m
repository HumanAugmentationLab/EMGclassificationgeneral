%Classification of PCA 

includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110t256', 'bp256t512',...
        'rms', 'iemg','mmav1','mpv','var', 'mav', 'zeros', 'mfl', 'ssi', 'medianfreq', 'wamp',...
        'lscale', 'dfa', 'wl', 'm2', 'damv' 'dasdv', 'dvarv', 'msr', 'ld', 'meanfreq', 'stdv', 'skew', 'kurt',...
         'np'};
includedchannels = [1:6:126 127:134];
selectedclassifier = {'linSVMmuli'};
response = traindata(:,'labels'); %labels

variablenames = traindata.Properties.VariableNames;
predictorNames = select_data(variablenames, includedfeatures, includedchannels);
predictors = traindata(:,predictorNames);

predictors_array = table2array(predictors);
coeff = pca(predictors_array);
princ_coeff = coeff(:,1:20); %only use first 20 principal component coefficents 
reduced_data = predictors_array*princ_coeff;

reduced_data_table = array2table(reduced_data);


kval = 5;
% Predictors are features
cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation

c = classification_accuracy(selectedclassifier, reduced_data_table, response, cpart);
fprintf('\nc = %.2f%%\n', c*100); %print accuracy