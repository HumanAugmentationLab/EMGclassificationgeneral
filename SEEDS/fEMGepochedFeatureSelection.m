% Feature selection and classification for EMG data
% Sam Michalka 6/30/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% File name setting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_data = true; %True if you want to load the data from the folder below, false if you already have the data loaded as an EEG
if load_data
    clearvars -except load_data
    dir_input =  'C:\Users\saman\Documents\MATLAB\EMGdata\RawSubj\'; %Must end in slash, this one is for Sam
    fname_input = '-alldata'; % Tag for file name (follows subject name)
end

save_output = true; % True if you want to save a features file
dir_output = 'C:\Users\saman\Documents\MATLAB\EMGdata\FeaturesSubj\';
fname_output = '-allfeatures'; %Tag for file name (follows subject name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Subject and other settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjectnumbers = 1; %Can be a vector with multiple numbers or just an integer

% If you want all conditions then use [];
condnames =  []; %{"DOWN pressed", "SPACE pressed"};

dotrainandtest = true; %If false, do train only and cross validate
% You might do false if you have very little data or if you have a separate
% test set in another file
holdoutfortest = 0.25; %Fraction of data to hold out for test
makebalanced = true; %If true, make sure there are the same number of conditions for each category


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Channel, features, and time window settings %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
includedchannels = [];%1:2; %channels to included, this will calculate features for each separately 
%(if you have cross channel features, you need to write something in to
%skip in order to avoid repeat features)
% [] for all channels

%Keep this one as all feature, but sometimes comment it out
includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110to256', 'bp256to512', 'rms', 'iemg','mmav1','var','mpv','var','ssi'};
% Subset of features to use
%includedfeatures = {'rms','var','mpv'};

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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Balance data if option is true %%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Select which conditions to include in your analysis and if you want to balance your data
    if makebalanced
        mydata = EEG.data;
        % Loop through labels and count how many of each condition
        for c = 1:length(condnames)
            num_trials(c) = sum(EEG.epochlabelscat==condnames{c});
        end
        num_trialspercond = min(num_trials); %Find min condition
        clear idx bicx balidx
        for c = 1:length(condnames)
            idx{c,:} = find(EEG.epochlabelscat==condnames{c});
            bicx(c,:) = idx{c}(randperm(length(idx{c}),num_trialspercond));
        end
        balidx = reshape(bicx,[],1);
        balidx = balidx(randperm(length(balidx)));
        EEG.data = mydata(:,:,balidx); % Replace data with subset of data
        EEG.epochlabelscat = EEG.epochlabelscat(balidx); %Replace labels with subset of labels
        EEG.trials = length(EEG.epochlabelscat); %New trials count
        clearvars mydata idx balidx bicx
    end

    % If only choosing a subset of conditions, pick out appropriate trials
    idxtrials = [];
    if isempty(condnames)
        idxtrials = 1:length(EEG.epochlabelscat);
    else
        for c = 1:length(condnames)
            condname = condnames{c};
            idxtrialsC = find(EEG.epochlabelscat==condname);
            idxtrials = [idxtrials idxtrialsC];
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Select subset of channels if appropriate
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(includedchannels)
        EEG.data = EEG.data(includedchannels,:,:);
        EEG.chanlocs.labels = EEG.chanlocs.labels(includedchannels,:); % TODO: May need to fix this in the future if labels changes format
    else 
        includedchannels = 1:size(EEG.data,1);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do additional preprocessing: filter, remove mean or baseline from trials 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for channel =1:size(EEG.data,1)
        % First, save the power in the frequency domain
        %[EEG.freqcalcs.P(channel,:,:),EEG.freqcalcs.F] = pspectrum(squeeze(EEG.data(channel,:,:)),EEG.timessec);
        if options.preprocess.meanremoval
            %Trial by trial baseline removal (can also do pre-event baseline removal
            %instead
            EEG.data(channel,:, :) = EEG.data(channel,:, :) - mean(EEG.data(channel,:, :),2);
        end
        if options.preprocess.filter
            % additional filtering (might want to do this with the continuous data
            % instead, if you find somethign you like)
            EEG.data(channel,:, :) = highpass(squeeze(EEG.data(channel,:, :)),20,EEG.srate);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Train/test separation 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ttpartgroups = removecats(EEG.epochlabelscat(idxtrials))';

    if dotrainandtest     
        rng(101); %Do this to theoretically get the same
        ttpart = cvpartition(ttpartgroups,'HoldOut',holdoutfortest);

        % Set up table of data that includes the trial labels
        traindata = table(EEG.epochlabelscat(idxtrials(ttpart.training))',idxtrials(ttpart.training)','VariableNames',{'labels','origEEGtrialidx'});
        traindata.labels = removecats(traindata.labels); % This remove the other trial catgories that we're not using here from the train data, which will prevent a warning

        %This table includes the original trial numbers, but we may want to remove
        %this for actually running the analysis

        testdata = table(EEG.epochlabelscat(idxtrials(ttpart.test))',idxtrials(ttpart.test)','VariableNames',{'labels','origEEGtrialidx'});
        testdata.labels = removecats(testdata.labels);

    else %Otherwise all the data is training
        traindata = table(EEG.epochlabelscat(idxtrials)',idxtrials','VariableNames',{'labels','origEEGtrialidx'});
        traindata.labels = removecats(traindata.labels); % This remove the other trial catgories that we're not using here from the train data, which will prevent a warning
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create time bins to loop through in feature selection 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    w.starttimes = w.totaltimewindow(1):(w.timewindowbinsize-w.timewindowoverlap):w.totaltimewindow(2);
    w.endtimes = (w.totaltimewindow(1)-1+w.timewindowbinsize):(w.timewindowbinsize-w.timewindowoverlap):w.totaltimewindow(2);
    if w.totaltimewindow(2) - w.starttimes(end) <= w.timewindowoverlap %if increment is smaller than the overlap window
        w.starttimes(end) = []; %then remove the last one (avoids indexing problem, plus you've already used this data)
    end
    if length(w.starttimes) > length(w.endtimes)
        w.endtimes = [w.endtimes w.totaltimewindow(2)];
        warning('The timewindowbinsize does not split evenly into the totaltimewindow, last window will be smaller')
        w.endtimes - w.starttimes
    end
    w.alltimewindowsforfeatures = [w.starttimes; w.endtimes]; %(:,1) for first pair

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop through all desired features and put into data table
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for ttround = 1:2
        % Deal with sometimes training only and sometimes training and test
        if ttround == 1
            %Do training data first
            tempdata = traindata;
            if dotrainandtest
                idxt = idxtrials(ttpart.training);
            else
                idxt = idxtrials;
            end
        elseif ttround == 2
            tempdata = testdata;
            idxt = idxtrials(ttpart.test);
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Add features to the data table
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for ch = includedchannels %not necessarily a linear index, so be careful
            for f = 1:length(includedfeatures)
                fvalues =[]; %clear and initialize fvalues
                for  tw = 1:size(w.alltimewindowsforfeatures,2)
                    timewindowforfeatures = w.alltimewindowsforfeatures(:,tw);
                    timewindowepochidx = (find(EEG.times>=timewindowforfeatures(1),1)):(find(EEG.times>=timewindowforfeatures(2),1));
                    
                    %mydata is a subset of the data for the channel,
                    %timewindow, and selected indices (train/test and
                    %conditions)
                    mydata = squeeze(EEG.data(ch,timewindowepochidx,idxt)); 
                    
                    % Note: because we're looping through multiple time
                    % bins, it's important to  check the size of the
                    % features going into fvalues. Should be trials x
                    % feature 
                    % Calcuate actual features by name in loop
                    switch includedfeatures{f}
                        case 'absmean'
                            fvalues = [fvalues mean(abs(mydata))']; % 
                        case 'rms'
                            fvalues = [fvalues rms(mydata)'];                   
                        case 'iemg'
                            fvalues = [fvalues sum(abs(mydata))'];
                        case 'ssi' %TODO: fix so not same as iemg or exclude
                            fvalues = [fvalues squeeze(sum(abs(EEG.data(ch,timewindowepochidx,idxt)), 2))];
                            % This could instead be done with the integral, which gives a smaller but correlated number if rectified
                            %ctr = squeeze(cumtrapz(EEG.timessec(timewindowepochidx), abs(EEG.data(ch,timewindowepochidx,idxt))));
                            %fvalues = ctr(end,:)'; % This could be useful if you
                            %wanted to take the diff between different increments.
                        case 'mpv'
                            fvalues = [fvalues max(mydata)'];
                        case 'mmav1'
                            low = prctile(mydata,25,1);
                            high = prctile(mydata,75,1);
                            weightedVals = mydata; %SWM: added idxt
                            weightedVals(weightedVals < low) = weightedVals(weightedVals < low)*.5;
                            weightedVals(weightedVals > high) = weightedVals(weightedVals > high)*.5;
                            fvalues = [fvalues mean(abs(weightedVals))'];
                        case 'var'
                            fvalues = [fvalues var(mydata)'];
                        case 'bp2t20'                       
                            fvalues = [fvalues bandpower(mydata,EEG.srate,[2 20])'];
                        case 'bp20t40'             
                            fvalues = [fvalues bandpower(mydata,EEG.srate,[20 40])'];
                        case 'bp40t56'                       
                            fvalues = [fvalues bandpower(mydata,EEG.srate,[40 56])'];
                        case 'bp64t80'
                            fvalues = [fvalues bandpower(mydata,EEG.srate,[64 80])'];
                        case 'bp80t110'
                            fvalues = [fvalues bandpower(mydata,EEG.srate,[80 110])'];
                        case 'bp110to256'
                            fvalues = [fvalues bandpower(mydata,EEG.srate,[110 256])'];
                        case 'bp256to512'
                            fvalues = [fvalues bandpower(mydata,EEG.srate,[256 512])'];
                        case 'medianfreq' %TODO: check this code. real after median? are these the right dims?
                            fvalues = [fvalues real(median(fft(mydata,'',1)))];
                            %fvalues = [fvalues squeeze(real(median(fft(EEG.data(ch,timewindowepochidx,idxt), '', 2), 2)))];
                        case 'mfl' %TODO: double check this code
                            fvalues = [fvalues real(log10(sqrt(sum(diff(mydata).^2))))'];
                            %fvalues = [fvalues squeeze(real(log10(sqrt(sum(diff(EEG.data(ch,timewindowepochidx,idxt)).^2, 2)))))];
                        case 'wamp' % Wilson Amplitude %TODO: check this code
                            % There is almost definitely a better way to do
                            % this.
                            threshold = 0.05;
                            shifted = circshift(mydata,1,1);
                            wamp_sum = sum(abs(mydata) + threshold < abs(shifted));
                            %shifted = circshift(EEG.data(ch,timewindowepochidx, idxt), 1, 2);
                            %wamp_sum = sum(abs(EEG.data(ch,timewindowepochidx, idxt)) + threshold < (abs(shifted)), 2);
                            fvalues = [fvalues wamp_sum'];
                        otherwise
                            disp(strcat('unknown feature: ', includedfeatures{f},', skipping....'))
                    end
                end

                % Make sure fvalues is the right shape !!!!!!!!!!!!!!!!!
                if size(squeeze(fvalues),1) ~= length(idxt)
                    warning(strcat('fvalues does not fit in data table, skipping feature: ', includedfeatures{f},...
                        '. _  Please fix the code to align shapes. Num trials: ',num2str(length(idxt)),...
                        ' and size fvalues : ',num2str(size(fvalues))))
                else
                    % Put fvalues into the datatable with appropriate feature name
                    eval(['tempdata.FEAT_ch' num2str(ch) '_' includedfeatures{f} ' = fvalues;']);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Put data into appropraite traindata or testdata variable
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ttround == 1
            %Do training data first
            %traindata = tempdata;
            % Randomly permute the data so not ordered
            traindata = tempdata(randperm(height(tempdata)),:);
            clear tempdata;
            if ~dotrainandtest % Check to see if you're only doing training data
                break;
            end
        elseif ttround == 2
            %testdata = tempdata;
            %Randomly permute the test data
            testdata = tempdata(randperm(height(tempdata)),:);
            clear tempdata
        end  
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save the features into .mat file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if save_output
        if dotrainandtest
            save(strcat(dir_output,'subj',num2str(subjectnumbers(s),'%02.f'),fname_output,'.mat'),'traindata','testdata','includedfeatures','includedchannels','subjectnumbers');
        else
            save(strcat(dir_output,'subj',num2str(subjectnumbers(s),'%02.f'),fname_output,'.mat'),'traindata','includedfeatures','includedchannels','subjectnumbers');
        end
    end
end
        
