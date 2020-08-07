%Find the features that were selected the most times by the feature
%selection methods

features = ["dasdv" 'rms' 'mmav1' 'lscale' 'stdv' 'mav' 'damv' 'dvarv' 'mmav1' 'dasdv' 'lscale' 'damv' 'rms' 'stdv' 'mav' 'ld' 'mav' 'mmav1' 'lscale' 'rms' 'ld' 'meanfreq' 'stdv' 'damv' 'lscale' 'mav' 'ld' 'rms' 'mmav1' 'stdv' 'var ' 'dasdv' 'dasdv' 'lscale' 'mav' 'rms' 'stdv' 'mmav1' 'meanfreq' 'mpv' 'dasdv' 'zeros' 'wamp' 'bp110t256' 'dvarv' 'damv' 'mmav1' 'meanfreq' 'mmav1' 'zeros' 'dfa' 'meanfreq' 'mav' 'bp110t256' 'mpv' 'np' 'mav' 'meanfreq' 'mmav1' 'np' 'medianfreq' 'stdv' 'iemg' 'dvarv' 'lscale' 'zeros' 'mav' 'mpv' 'rms' 'meanfreq' 'bp110t256' 'stdv' 'dasdv' 'meanfreq' 'var ' 'bp80t110' 'np' 'lscale' 'medianfreq' 'bp40t56' 'wamp' 'zeros' 'var ' 'mpv' 'rms' 'bp110t256' 'bp20t40' 'meanfreq' 'medianfreq' 'var ' 'mpv' 'rms' 'bp110t256' 'bp80t110' 'np' 'medianfreq' 'zeros' 'var ' 'bp256t512' 'bp40t56' 'bp20t40' 'zeros' 'var ' 'bp110t256' 'bp80t110' 'bp64t80' 'bp40t56' 'bp20t40' 'bp2t20' 'dasdv' 'lscale' 'wamp' 'medianfreq' 'zeros' 'mpv' 'mmav1' 'rms' 'bp80t110' 'bp40t56' 'bp20t40' 'bp2t20'];
unique_features = unique(features); %creates list of unique features

X = categorical(unique_features);
X = reordercats(X,unique_features);

for n = 1:length(unique_features)
    occurrence(n) = sum(count(features, unique_features(n))); %counts times each feature appears
end 
    
bar(X, occurrence) %creates a bar graph of each unique feature and how many times it appears
title('Times Each Feature was Selected')
xlabel('Number of Times Selected')
ylabel('Feature')
