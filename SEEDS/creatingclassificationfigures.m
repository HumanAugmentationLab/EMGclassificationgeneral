%creating table of individual feature classification accuracies
%and a graph of how the accuracy changes as you add features

%dir_input = 'C:\Users\saman\Documents\MATLAB\EMGdata\FeaturesSubj\'; %Sam's 
dir_input = 'C:\Users\dketchum\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Declan's 
fname_input = '-allfeatures'; %Tag for file name (follows subject name)

includedspeeds={'both','slow','fast'};%
sp = 2;
subjectnumbers = 6;
s=1; %This is here to make loops later
load(strcat(dir_input,'subj',num2str(subjectnumbers(s),'%02.f'),fname_input,'_speed',includedspeeds{sp},'.mat'))

includedchannels = [1:6:126 127:134]; % [] for all, otherwise this is a vector of channel numbers

kval = 9;% %Choose number of folds.
dotrainandtest = false; % If running on test as well as train

selectedclassifier = {'linSVMmuli'};

traindata = splitvars(traindata); %split subvariables into independent variable to not anger the classifier.

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
    
    acc_includedfeatures(f) = validationAccuracy; %individual feature validation accuracies

end

%order features based on validation accuracy
%add one feature at a time and run classification. record classification in
%an array 
%plot the list of features in order agains the classifcation accuracy array

