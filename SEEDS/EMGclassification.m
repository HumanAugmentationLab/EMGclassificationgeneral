
dir_input = 'C:\Users\saman\Documents\MATLAB\EMGdata\FeaturesSubj\'; %Sam's 
%dir_input = 'C:\Users\dketchum\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Declan's
dir_input = 'C:\Users\msivanandan\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Maya's

% fname_input = '-allfeatures'; %Tag for file name (follows subject name)
% fname_input = '-PARAMETERSWEEPfeaturesChA';
% fname_input = '-PARAMETERSWEEPfeaturesChB';
% fname_input = '-PARAMETERSWEEPfeaturesChC';
% fname_input = '-PARAMETERSWEEPfeaturesChD';
% fname_input = '-PARAMETERSWEEPfeaturesChE';
 fname_input = '-PARAMETERSWEEPfeaturesChF';


includedspeeds={'both','slow','fast'};%
sp = 1;
subjectnumbers = 3;
s=1; %This is here to make loops later
load(strcat(dir_input,'subj',num2str(subjectnumbers(s),'%02.f'),fname_input,'_speed',includedspeeds{sp},'.mat'))

includedchannels = []; % [] for all, otherwise this is a vector of channel numbers

kval = 5;% %Choose number of folds.
dotrainandtest = false; % If running on test as well as train

selectedclassifier = {'linSVMmuli'};

traindata = splitvars(traindata); %split subvariables into independent variable to not anger the classifier.

%% Run classification on all features in included features 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select data for the channels you want
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(includedchannels)
    % Include all features
    predictorNames = traindata.Properties.VariableNames(contains(traindata.Properties.VariableNames,'FEAT_'));
else
    idx_feat = contains(traindata.Properties.VariableNames,'FEAT_'); % Find all of 
    names_ch = cellstr([repmat('_ch',length(includedchannels),1)  num2str(includedchannels') repmat('_',length(includedchannels),1) ]); 
    names_ch = strrep(names_ch,' ',''); % Remove spaces
    idx_ch = contains(traindata.Properties.VariableNames,names_ch);
    predictorNames = traindata.Properties.VariableNames(idx_ch & idx_feat); %column names that are FEAT and are the channels we want to include
end


% Predictors are features
predictors = traindata(:,predictorNames); %This is the X
response = traindata(:,'labels'); %labels
cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select the classifiers you want
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
validationAccuracy = 1 - kfoldLoss(partitionedModel);%, 'LossFun', 'ClassifError');
fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy*100);
trainconchart = confusionchart(traindata.labels,validationPredictions);
trainconchart.NormalizedValues;
validationAccuracy = sum(traindata.labels==validationPredictions)./length(traindata.labels);
fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy*100);


%% Run classification on on each feature in includedfeatures separately
acc_includedfeatures = zeros(length(includedfeatures),1);

% Get y (repsonse and set up cross validation partition)
response = traindata(:,'labels'); %labels
cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation
    
for f = 1:length(includedfeatures)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Select data for the channels you want
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(includedchannels)
        % Include all features
        idx_feat = contains(traindata.Properties.VariableNames,'FEAT_'); % Find all of ones that start with FEAT_
        idx_selfeat = contains(traindata.Properties.VariableNames,strcat('_',includedfeatures{f}));
        predictorNames = traindata.Properties.VariableNames(idx_selfeat & idx_feat); %column names that are FEAT and are the channels we want to include
    else 
        idx_feat = contains(traindata.Properties.VariableNames,'FEAT_'); % Find all of ones that start with FEAT_
        names_ch = cellstr([repmat('_ch',length(includedchannels),1)  num2str(includedchannels') repmat('_',length(includedchannels),1) ]); 
        names_ch = strrep(names_ch,' ',''); % Remove spaces
        idx_ch = contains(traindata.Properties.VariableNames,names_ch);
        idx_selfeat = contains(traindata.Properties.VariableNames,strcat('_',includedfeatures{f}));
        predictorNames = traindata.Properties.VariableNames(idx_ch & idx_feat & idx_selfeat); %column names that are FEAT and are the channels we want to include
    end


    % Predictors are features
    clearvars predictors 
    predictors = traindata(:,predictorNames); %This is the X
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Select the classifiers you want
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    validationAccuracy = 1 - kfoldLoss(partitionedModel);%, 'LossFun', 'ClassifError');
    fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy*100);
    trainconchart = confusionchart(traindata.labels,validationPredictions);
    trainconchart.NormalizedValues;
    validationAccuracy = sum(traindata.labels==validationPredictions)./length(traindata.labels);
    fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy*100);
    
    acc_includedfeatures(f) = validationAccuracy;

end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Old code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% imbalancedcostmatrix.ClassNames = unique(response{:,1}); 
% imbalancedcostmatrix.ClassificationCosts =  [0 sum(traindata.labels == imbalancedcostmatrix.ClassNames(2)); sum(traindata.labels == imbalancedcostmatrix.ClassNames(1)) 0];
% %imbalancedcostmatrix.ClassificationCosts
% trainedClassifier = fitcsvm(predictors, ...
%     response, ...
%     'KernelFunction', 'Linear', ...
%     'Standardize',true);%,...  
%     %'Prior','empirical');%,...
%     %'Cost',imbalancedcostmatrix );  % Rows are true for cost matrix
   
%trainedClassifier = fitcecoc(predictors,response,'KernelFunction', 'Linear');
%'OutlierFraction',0.15,...

% % k-fold cross validation
% kval = 5;%min(5,height(response)-2); %Choose number of folds. You can also just set this manually.
% cpart = cvpartition(response{:,1},'KFold',kval); % k-fold stratified cross validation
% partitionedModel = crossval(trainedClassifier,'CVPartition',cpart);
% [validationPredictions, validationScores] = kfoldPredict(partitionedModel);
%      
% % Cross validation output
% validationAccuracy = 1 - kfoldLoss(partitionedModel);%, 'LossFun', 'ClassifError');
% fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy*100);
% trainconchart = confusionchart(traindata.labels,validationPredictions);
% % ,'Normalization','row-normalized'
% % 
% trainconchart.NormalizedValues
% 
% if dotrainandtest
%     testdata = splitvars(testdata); %split subvariables into variables
%     
%     % Code for prediction of test data (stored here for later)
%     [predictedlabel,score] = predict(trainedClassifier,testdata(:,predictorNames));
%     testAccuracy = sum(testdata.labels==predictedlabel)./length(testdata.labels);
%     fprintf('\nTest accuracy = %.2f%%\n', testAccuracy*100);
%     figure;
%     testconchart = confusionchart(testdata.labels,predictedlabel);%,'Normalization','row-normalized'
%     testconchart.NormalizedValues
% end