# EMGclasificationgeneral - SEEDS
DFAfunc.m - Detrended Fluctuation Analysis Feature Function

EMGClassificationwithFunctions.m  - EMG Classification using classification_accurcy function.

EMGFeatureExtraction.m - Apply selected features on the data (Feature extraction) - come back to this

EMGFeatureSelection.m - Select which features we would like to use with our data by adding each feature and checking the validation accuracy

channelCorrelationFunc.m  - Iterates through each feature and creates a correlation matrix for
all channels for a given feature.Then, takes the mean of correlation coefficients across features for each channel. The output is a correlation matrix of this mean of correlation coefficients.

classification_accuracy.m - Function which finds the classification accuracy with a given set of training data, a classifier, and the predictor names. Returns the validation accuracy as a decimal.

featureCorrelationFunc.m -  Makes a correlation matrix of all features for each channel. Then takes the mean of correlation coefficients across channels for each feature. The output is a correlation matrix of this mean of correlation coefficients.

Loaddatafrommat.m - These scripts can help you load data from multiple .mat files provided in the SEEDs database.

Lscale.m - L-scale Feature Function.

rawDataCorrelation.m - Code for creating a correlation matrix for all the raw (SEEDS) data.

Seeds_feat_corr.png  - Mean Correlation Matrix of SEEDS Features (features x features).

Select_data.m -  Input a list of the indices of features to be included in the classification. Returns a matrix that only includes the data of the included features.

subjFeatCorrFunc.m  - For each subject data, call featureCorrelationFunc. Then, store the correlation matrix for each subject data and take the average across all the subjects to give a feature x feature correlation matrix.

EMGclassification.m - compare this wih emgfeatextract 

EnviornmentSetUp.m - we should all update this with our links?
