%IN PROGRESS


% Initial data loading from
% Feature selection and classification for EMG data
% Sam Michalka 6/30/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% File name setting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_data = true; %True if you want to load the data from the folder below, false if you already have the data loaded as an EEG
if load_data
    %clearvars -except load_data %had re delete this for enviornment set up
    %to work (but it might be important)
    %dir_input =  'C:\Users\saman\Documents\MATLAB\EMGdata\RawSubj\';%Must end in slash, this one is for Sam
    %dir_input = 'C:\Users\dketchum\Documents\Summer Research 2020\'; %Declan's
    %dir_input = 'C:\Users\rsarin\Desktop\EMG Research\Day 17\'; %Rishita's
    dir_input = my_dir; %can use this once you have made your own enviornment file and run it
    fname_input = '-alldata'; % Tag for file name (follows subject name)
end

save_output = true; % True if you want to save a features file
%dir_output = 'C:\Users\saman\Documents\MATLAB\EMGdata\FeaturesSubj\'; %Sam's 
%dir_output = 'C:\Users\dketchum\Documents\Summer Research 2020\'; %Declan's 
dir_output = 'C:\Users\msivanandan\Desktop\HAL Summer 2020\SEEDS Database\'; %Maya's
%dir_output = my_dir;
%dir_output = 'C:\Users\rsarin\Desktop\EMG Research\Day 17\';

fname_output = '-rawDataConfMatrix'; %Tag for file name (follows subject name)
% >>>>>>> a68d50f04f4143b561202e476d5c1c06e185dfe1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Subject and other settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjectnumbers = 3;%sub_num; %Can be a vector with multiple numbers or just an integer

% If you want all conditions then use [];
condnames =  []; %{"DOWN pressed", "SPACE pressed"};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Channel, features, and time window settings %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
includedchannels = [];%1:2; %channels to included, this will calculate features for each separately 
%(if you have cross channel features, you need to write something in to
%skip in order to avoid repeat features)
% [] for all channels

% Choose which speed to include: both puts them in the same file, slow or
% fast puts them separately. This will loop through all the options below
% and write a file for each
includedspeeds = {'both'}; 
%Opitions: 'both', 'slow', or 'fast'


% Time windows and overlap (when breaking window up into multiple bins)
w.totaltimewindow = [2000 4000]; %start and stop in ms. If timepoints don't line up, this will select a slightly later time
w.timewindowbinsize = 2000; %This should ideally divide into an equal number of time points
w.timewindowoverlap = 0; %Overlap of the time windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%            Preprocessing settings           %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.preprocess.meanremoval = false;
options.preprocess.filter = false;

% Load subject data
for s=1:length(subjectnumbers)
    if load_data %if you're loading data from .mat files
        load(strcat(dir_input,'subj',num2str(subjectnumbers(s),'%02.f'),fname_input,'.mat'));
    else %if the data is already in your workspace, labeled ALLEEG or EEG
        if exists('ALLEEG'); EEG = ALLEEG{s}; 
        else; warning('ALLEEG does not exist, using EEG as data source, might be the same for all subjects'); end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Select speeds %%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop through the options for included speeds and make an output for
    % each
    for sp = 1:length(includedspeeds)
        % TODO: Make this more data efficient. This is a lazy way to code
        % this, you could instead index throughout the code if you end up
        % running into memory problems.
        if sp==1; origEEG = EEG; end %store the data the first time through
        EEG = origEEG; % start with all the data all the data
        if strcmp('both',includedspeeds{sp})               
            disp('Using both slow and fast data')
        else
            disp(['Using just the ', includedspeeds{sp}, ' data'])
            idxselspeed = (EEG.speed==includedspeeds{sp});
            EEG.data=EEG.data(:,:,idxselspeed);
            EEG.movement = EEG.movement(idxselspeed);
            EEG.speed = EEG.speed(idxselspeed);
            EEG.triallabels = EEG.triallabels(EEG.speed);
            EEG.trials = sum(idxselspeed);
            if isfield(EEG,'glovedata'); EEG.glovedata = EEG.glovedata(:,:,idxselspeed); end %Only try to update glove data if it exists
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% Select conditions %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Add some info to the EEG structure to make life easier (trial labels)
        EEG.timessec = EEG.times./1000; %version of times in seconds, useful for signal processing
        % Labels used for this classification
        EEG.epochlabelscat = EEG.movement; %Movement if classifying different hand positions

        % Note: This is a good place to create new trial labels, for example, if
        % you wanted to make new categories that are combinations of multiple
        % categories

        %make an array of all possible labels of events in your data
        availableeventlabels = unique(EEG.epochlabelscat);
        if isempty(condnames)
            condnames = cellstr(availableeventlabels);
        end
        condnames = cellstr('thumbFlex');
        
        idxtrials = [];
        if isempty(condnames)
            idxtrials = 1:length(EEG.epochlabelscat);
        else
            for c = 1:length(condnames)
                condname = condnames{c};
                idxtrials = find(EEG.epochlabelscat==condname);
                for t = 1:length(idxtrials)
                    corrMatTemp = (corr((EEG.data(:,:,idxtrials(t)))'));
                    if t == 1
                        corrMat = corrMatTemp;
                     else
                        corrMat = cat(3, corrMat, corrMatTemp); 
                    end
                end
            end
        end
    end
end

figure
imagesc(corrMat(:,:,1))
title('Mean correlation matrix of all Features');
xlabel('FEATURES');
xticks([1 2 3 4 5]); %temporary fix for #features - ideally would like to have name of feature as a tick. 
yticks([1 2 3 4 5]); %same as x tick
ylabel('FEATURES');
c = colorbar;
c.Label.String = 'Correlation Coefficient';
c = colorbar;