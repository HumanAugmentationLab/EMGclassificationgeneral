# EMGclasificationgeneral - SEEDS

ChannelCorrBySubj.m - Create correlation matrices for each subject. Correlations are channel x channel (averaged across selected features). Calls on channelCorrelationFunc.m.

ChannelCorrGridViz.m - View channel correlations with spatial layout of actual EMG arm grid.

DFAfunc.m - Detrended Fluctuation Analysis Feature Function.

EMGClassificationwithFunctions.m  - EMG Classification using classification_accurcy function.

EMGFeatureExtraction.m - Extract Features from EMG data.

EMGFeatureExtractionWithPCA.m - Conduct PCA on EMGFeatureExtraction for dimensionality reduction (to make code faster without losing out on accuracy).

EMGFeatureSelection.m - Select which features we would like to use with our data by adding each feature and checking the validation accuracy.

EMGclassification.m - Run classifier on the results we get from feature extraction to attain classification accuracy.

FeatureCorrBySubj.m - Create correlation matrices for each subject. Correlations are feature x feature (averaged across channels). Calls on featureCorrelationFunc.m.

Mobility.m - Hjorth's Mobility Parameter Feature Function.

SelectionAdditionSubtractionCheck.m - Algorithm passes through all features, adding one feature at a time and calculating its accuracy. If the accuracy increases with feature addition, algorithm keeps the feature in a list of included features. Once algorithm passes through all features and creates a list of included features, it takes the included features and starts by removing features from the bottom of the list. If the classification accuracy doesn't decrease when the feature is removed, we permanently remove it from the included features list. By the end, we are left with the minimal number of features required to attain the highest classification accuracy.

SelectionofBestFeatures.m - Run SVM classification on one feature at a time and collect the validation accuracies for each feature. The algorithm orders the features from best to worst individual classification accuracy. It then adds each feature in order to a list of included features and runs the classification. 

channelCorrelationFunc.m  - Iterates through each feature and creates a correlation matrix for all channels for a given feature.Then, takes the mean of correlation coefficients across features for each channel. The output is a correlation matrix of this mean of correlation coefficients.

classification_accuracy.m - Function which finds the classification accuracy with a given set of training data, a classifier, and the predictor names. Returns the validation accuracy as a decimal.

classificationwpca.m - runs Linear SVM classifier with PCA to output classification accuracy. Calls upon classification_accuracy.m.

featureCorrelationFunc.m -  Makes a correlation matrix of all features for each channel. Then takes the mean of correlation coefficients across channels for each feature. The output is a correlation matrix of this mean of correlation coefficients.

Loaddatafrommat.m - These scripts can help you load data from multiple .mat files provided in the SEEDs database and compile them into 1 .mat file ('-alldata').

Lscale.m - L-scale Feature Function.

plot_corr.m - Plots correlation matrix - (makes all the correlation functions shorter in length with this as a seperate function).

rawDataCorrelation.m - Code for creating a correlation matrix for all the raw (SEEDS) data.

Seeds_feat_corr.png  - Mean Correlation Matrix of SEEDS Features (features x features).

Select_data.m -  Input a list of the indices of features to be included in the classification. Returns a matrix that only includes the data of the included features.

EnviornmentSetUp.m - we should all update this with our links?
