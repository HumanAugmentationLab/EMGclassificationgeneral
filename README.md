# EMGclasificationgeneral
DFAfeatureExtract.mlx - Calls DFAfunc.m to extract DFA feature.

FractalDim.m - Fractal Dimension Feature Function.

Mobility.m - Hjorth's Mobility Parameter Feature Function.

NeurotechsmilefrownangryblinkS1filt0p5notch56t64epochs.mat - Data Sam collected by placing electrodes on the zygomaticus major + corrugator supercilii. She expressed emotions for each trial to see if we can predict emotions based on neuron signals.
 
Summer 2020 EEG Epoch.mlx - Attain best classification rate for Sam’s data by playing around with features, classification algorithms, time windows, etc. The current version looks to differentiate between “angry” and “smiling” data.

Classification_loop.mlx - Loop through all features for Sam's data to find their validation accuracy. We were able to determine which features were the best for this dataset (the features with the highest validation accuracy). 

code_behind_classLearner.mlx - Walks through each step of finding the best classifier with the highest percent accuracy and compares it with the steps used with classificationLearner.

Code_for_classifiers.mlx - Compilation of code for each classifier (Linear SVM, Decision Tree, etc). Allows for easy access to classifier types + their code. Essentially, you may copy-paste sections from this file in the main file to test out different types of classifications on the dataset. 

Features_matlab_code.mlx - Compilation of code for each feature we explored this summer. Essentially, you may copy-paste sections from this file in the main file to test out different features with your dataset.


Sampen.m - Sample Entropy Feature Function.

