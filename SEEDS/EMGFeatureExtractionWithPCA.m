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
%dir_output = 'C:\Users\saman\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Sam's 
%dir_output = 'C:\Users\dketchum\Documents\Summer Research 2020\'; %Declan's
%dir_output = 'C:\Users\dketchum\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Declan's Google
dir_output = 'C:\Users\msivanandan\Google Drive\HAL\Projects\ArmEMG\Data\SEEDS\FeaturesSubj\'; %Maya's
%dir_output = my_dir;
%dir_output = 'C:\Users\rsarin\Desktop\EMG Research\Day 17\';

% fname_output = '-SEEDSfeatures'; %Tag for file name (follows subject name)
% fname_output = '-allfeatures'; %Tag for file name (follows subject name)
% fname_output = '-testingMAVS'; 
% fname_output = '-PARAMETERSWEEPfeaturesChA';
% fname_output = '-PARAMETERSWEEPfeaturesChB';
 fname_output = '-PARAMETERSWEEPfeaturesChC';
% fname_output = '-PARAMETERSWEEPfeaturesChD';
% fname_output = '-PARAMETERSWEEPfeaturesChE';
% fname_output = '-PARAMETERSWEEPfeaturesChF';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Subject and other settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjectnumbers = 3;%sub_num; %Can be a vector with multiple numbers or just an integer

% If you want all conditions then use [];
condnames =  []; %{"DOWN pressed", "SPACE pressed"};

dotrainandtest = false; %If false, do train only and cross validate
% You might do false if you have very little data or if you have a separate
% test set in another file
holdoutfortest = 0.25; %Fraction of data to hold out for test
makebalanced = false; %If true, make sure there are the same number of conditions for each category

             
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
includedspeeds = {'both'};%,'slow','fast'}; 

% Subset of features to use
if strcmp(fname_output,'-allfeatures') %The list below should be updated to include all possible features
    includedfeatures = {'bp2t20','bp20t40','bp40t56','bp64t80' ,'bp80t110','bp110t256', 'bp256t512',...
        'rms', 'iemg','mmav1','mpv','var', 'mav', 'zeros', 'mfl', 'ssi', 'medianfreq', 'wamp',...
        'lscale', 'dfa', 'wl', 'm2', 'damv' 'dasdv', 'dvarv', 'msr', 'ld', 'meanfreq', 'stdv', 'skew', 'kurt',...
         'np'};
elseif strcmp(fname_output,'-SEEDSfeatures')
    includedfeatures = {'mav', 'var', 'rms', 'zeros', 'damv'}; %features included in SEEDS paper (damv is aac)
else %This list can be manually set to whatever you want, make sure you choose an appropriate fname_output above
    %includedfeatures = {'meanfreq', 'lscale', 'mmav1', 'mpv', 'stdv', 'damv', 'zeros', 'bp40t56'}; %currently slected features for parameter sweeping
    includedfeatures = {'meanfreq', 'lscale', 'mmav1', 'mpv', 'stdv', 'damv', 'zeros', 'bp40t56'};
end


% Time windows and overlap (when breaking window up into multiple bins)
w.totaltimewindow = [2000 4000]; %start and stop in ms. If timepoints don't line up, this will select a slightly later time
w.timewindowbinsize = 2000; %This should ideally divide into an equal number of time points
w.timewindowoverlap = 0; %Overlap of the time windows
dfabinsize = [273 315 585 819 1365];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Channel Selection PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Feature subset for parameter sweeping
usePCA = false; %This gets overwritten in some of the PCA options to be true
     
%Channel Parameter Options
%(Add directly to the end of fnameoutput tag, ex. '-PARAMETERSWEEPfeaturesChA')
%
%ChA: [1:19:126 130] 8 channels
%ChB: [1:6:126 127:134] 29 channels total
%ChC: Top 8 PCA components
%ChD: Top 29 PCA components
%ChE: [1:2:134] 50% of channels (from SEEDS paper)
%ChF: Last 2 PCA components
%
%Make sure includedfeatures = {'meanfreq', 'lscale', 'mmav1', 'mpv' 'stdv', 'damv', 'zeros', 'bp40t56'}; 
%in the else statement/manual list of feature subsets
if strcmp(fname_output,'-PARAMETERSWEEPfeaturesChA') 
     includedchannels = [1:19:126 130];
elseif strcmp(fname_output,'-PARAMETERSWEEPfeaturesChB') 
    includedchannels = [1:6:126 127:134];    
elseif strcmp(fname_output,'-PARAMETERSWEEPfeaturesChC')
    usePCA = true;
    includedcomponents = 1:8; %Need to set as components here so includedchannels doesn't preemtively downsize
    includedchannels = [];
elseif strcmp(fname_output,'-PARAMETERSWEEPfeaturesChD')
    usePCA = true;
    includedcomponents = 1:29; %Need to set as components here so includedchannels doesn't preemtively downsize
    includedchannels = [];
elseif strcmp(fname_output,'-PARAMETERSWEEPfeaturesChE')
    includedchannels = [1:2:134]; 
elseif strcmp(fname_output,'-PARAMETERSWEEPfeaturesChF')
    usePCA = true;
    includedcomponents = 133:134; %Need to set as components here so includedchannels doesn't preemtively downsize
    includedchannels = [];
end

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
%         if ~isempty(includedchannels)
%             EEG.data = EEG.data(includedchannels,:,:);
%             EEG.chanlocs.labels = EEG.chanlocs.labels(includedchannels,:); % TODO: May need to fix this in the future if labels changes format
%         else 
%             includedchannels = 1:size(EEG.data,1);
%         end
% Commented this out because ch is indexing through included channels not
% through 1:length of included channels.


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
            w.endtimes - w.starttimes;
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
            % Calculate PCA if usePCA = true
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %Potentially add an 'if exists' search for PCAdata
            if usePCA
                dataReshape = reshape(EEG.data, size(EEG.data,1), []);
                EEG.PCAcomponents = pca(dataReshape');
                for PCAtrialnum = 1:size(EEG.data,3)
                    EEG.PCAdata(:,:,PCAtrialnum) = EEG.PCAcomponents'*EEG.data(:,:,PCAtrialnum);
                end
                %EEG.PCAdata is components by data by trial

                origincludedchannels = includedchannels; % need to save this b/c looping through multiple subjects
                includedchannels = includedcomponents;
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
                        if usePCA
                            mydata = squeeze(EEG.PCAdata(ch,timewindowepochidx,idxt));
                        else
                            mydata = squeeze(EEG.data(ch,timewindowepochidx,idxt)); 
                        end
                        mytimes = EEG.times(timewindowepochidx);
                        freqdata = abs(fft(mydata));
                        % Note: because we're looping through multiple time
                        % bins, it's important to  check the size of the
                        % features going into fvalues. Should be trials x
                        % feature 
                        % Calcuate actual features by name in loop
                        switch includedfeatures{f}
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % Time domain features
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            case 'rms'
                                fvalues = [fvalues rms(mydata)'];                   
                            case 'iemg'
                                fvalues = [fvalues sum(abs(mydata))'];
                            case 'ssi' % Simple square integral - squared version of iEMG
                                fvalues = [fvalues sum(mydata.^2)'];
                                % This could instead be done with the integral, which gives a smaller but correlated number if rectified
                                %ctr = squeeze(cumtrapz(EEG.timessec(timewindowepochidx), abs(EEG.data(ch,timewindowepochidx,idxt))));
                                %fvalues = ctr(end,:)'; % This could be useful if you
                                %wanted to take the diff between different increments.
                            case 'm2' %second order moment, same as SSI but on the diff
                                fvalues = [fvalues sum(diff(mydata).^2)'];
                                
                            case 'wl' %waveform length (extension of iEMG but based on difference);
                                fvalues = [fvalues (sum(abs(diff(mydata))))'];  
                            case 'mav' %mean absolute value
                                fvalues = [fvalues mean(abs(mydata))'];
                            case 'damv' %difference absolute mean value - modified version of the MAV but on the difference
                                fvalues = [fvalues mean(abs(diff(mydata)))'];
                                %Also known as average amplitude change (aac),  modified to run on the difference, then known as difference absolute mean value (DAMV) (Kim et al., 2011);
                           
                            
                            case 'mpv'
                                mpv = [];
                                [row, col] = find(mydata > rms(mydata)); %index of peaks
                                for n = 1:size(mydata,2)      
                                    mpv(n) = mean(mydata(row(col==n),n));
                                end
                                fvalues = [fvalues mpv'];
                                
                            
                            case 'mmav1'
                                low = prctile(mydata,25,1);
                                high = prctile(mydata,75,1);
                                weightedVals = mydata; %SWM: added idxt
                                weightedVals(weightedVals < low) = weightedVals(weightedVals < low)*.5;
                                weightedVals(weightedVals > high) = weightedVals(weightedVals > high)*.5;
                                fvalues = [fvalues mean(abs(weightedVals))'];
                            case 'var'
                                fvalues = [fvalues var(mydata)'];
                            case 'dvarv' %difference variance value
                                % same as using var func, so using var for
                                % ease of reading
                                %fvalues = [fvalues ((sum((diff(mydata)).^2))/(size(mydata,1)-2))'];
                                fvalues = [fvalues var(diff(mydata))'];
                            
                            case 'np' %number of peaks
                                np = sum(mydata > rms(mydata), 1);
                                fvalues = [fvalues np'];
                            case 'dasdv' %difference absolute standard deviation value
                                fvalues = [fvalues sqrt(mean(diff(mydata).^2))'];
                            
                            case 'msr' %mean value of square root 
                                % Note: this deviates from original
                                % equation by using the abs to avoid
                                % complex numbers from the sqrt
                                fvalues = [fvalues (mean(sqrt(abs(mydata))))'];
                            case 'ld' %log detector
                                fvalues = [fvalues exp(mean(log(abs(mydata))))'];
                            case 'stdv' %standard deviation
                                fvalues = [fvalues (std(mydata))'];
                            case 'skew' %skewness
                                fvalues = [fvalues (skewness(mydata))'];
                            case 'kurt' %kurtosis
                                fvalues = [fvalues (kurtosis(mydata))'];
                               
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % Frequency domain features
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            case 'bp2t20' % Band power                      
                                fvalues = [fvalues bandpower(mydata,EEG.srate,[2 20])'];
                            case 'bp20t40'             
                                fvalues = [fvalues bandpower(mydata,EEG.srate,[20 40])'];
                            case 'bp40t56'                       
                                fvalues = [fvalues bandpower(mydata,EEG.srate,[40 56])'];
                            case 'bp64t80'
                                fvalues = [fvalues bandpower(mydata,EEG.srate,[64 80])'];
                            case 'bp80t110'
                                fvalues = [fvalues bandpower(mydata,EEG.srate,[80 110])'];
                            case 'bp110t256'
                                fvalues = [fvalues bandpower(mydata,EEG.srate,[110 256])'];
                            case 'bp256t512'
                                fvalues = [fvalues bandpower(mydata,EEG.srate,[256 512])'];
                            
                            case 'medianfreq' %median normalized frequency
                                %TODO: check this code. real after median? are these the right dims?
                                %fvalues = [fvalues (real(median(fft(mydata,'',1))))'];
                                %fvalues = [fvalues squeeze(real(median(fft(EEG.data(ch,timewindowepochidx,idxt), '', 2), 2)))];
                                fvalues = [fvalues (medfreq(mydata,EEG.srate))']; %Added 7/15/20
                            case 'meanfreq' %mean normalized frequency
                                fvalues = [fvalues (meanfreq(mydata,EEG.srate))']; 
                            
                            
                            case 'mfp' %mean frequency peak - TODO: REMOVE FROM TOP FOR NOW
                                % potential error in how freqdata is used
                                % here - might want the freqs not their
                                % powers
                                [row, col] = find(freqdata > rms(freqdata)); 
                                for n = 1:size(freqdata,2)      
                                    mfp(n) = mean(freqdata(row(col==n),n));
                                end
                                fvalues = [fvalues mfp];
                            case 'stdpk'%standard deviation of peaks - TODO: REMOVE FROM TOP FOR NOW
                                % potential error in how freqdata is used
                                % here - might want the freqs not their
                                % powers
                                [row, col] = find(freqdata > rms(freqdata)); 
                                for n = 1:size(freqdata,2)      
                                    stdpk(n) = std(freqdata(row(col==n),n));
                                end
                                fvalues = [fvalues stdpk];
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % Other features
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            case 'wamp' % Wilson Amplitude %TODO: check this code
                                % There is almost definitely a better way to do
                                % this.
                                %threshold = 0.05;
                                %shifted = circshift(mydata,1,1);
                                %wamp_sum = sum(abs(mydata) + threshold < abs(shifted));
                                %shifted = circshift(EEG.data(ch,timewindowepochidx, idxt), 1, 2);
                                %wamp_sum = sum(abs(EEG.data(ch,timewindowepochidx, idxt)) + threshold < (abs(shifted)), 2);
                                threshold = 0.05;
                                wamp = sum((abs(diff(mydata)))>threshold);
                                fvalues = [fvalues wamp'];
                            
                            case 'Hmob' %Hjorth mobility - TODO: REMOVE FROM TOP FOR NOW
                                fvalues = [fvalues Mobility(mydata, mytimes)];
                            case 'hcom' %Hjorth Complexity - TODO: REMOVE FROM TOP FOR NOW
                                HCom = Mobility((gradient(mydata)./gradient(mytimes)'), mytimes)./(Mobility(mydata, mytimes));
                                fvalues = [fvalues HCom]; 
                                
                            case 'zeros'
                                zcd = dsp.ZeroCrossingDetector;
                                fvalues = [fvalues double(zcd(mydata))'];
                            case 'lscale'
                                fvalues = [fvalues lscale(mydata)'];
                            case 'dfa'
                                fvalues = [fvalues DFAfunc(mydata,dfabinsize)];   
                                
                            case 'mfl' %code double checked by Rishita on 7/6/2020
                                fvalues = [fvalues real(log10(sqrt(sum(diff(mydata).^2))))'];
                                %fvalues = [fvalues squeeze(real(log10(sqrt(sum(diff(EEG.data(ch,timewindowepochidx,idxt)).^2, 2)))))];
                                
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
                save(strcat(dir_output,'subj',num2str(subjectnumbers(s),'%02.f'),fname_output,'_speed',includedspeeds{sp},'.mat'),'traindata','testdata','includedfeatures','includedchannels','subjectnumbers');
            else
                save(strcat(dir_output,'subj',num2str(subjectnumbers(s),'%02.f'),fname_output,'_speed',includedspeeds{sp},'.mat'),'traindata','includedfeatures','includedchannels','subjectnumbers');
            end
        end
        
        if usePCA
            includedchannels = origincludedchannels; %We reset this because we're looping through components and pretending that they are channels 
            %but there are other places in our code above that need the
            %original channels. This is sloppy, but will be fixed if we
            %move to calculating PCA in an earlier stage.
        end
        
    end % speeds
end %subj
        
