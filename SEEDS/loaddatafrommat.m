
% These scripts can help you load data from multiple .mat files provided in
% the SEEDs data base.

%% This settings help you load your specific data.

% This is the full file path for the folder that contains the subj* folder
%dir_root = 'C:\Users\saman\Documents\MATLAB\EMGdata\'; %Must end in slash, this one is for Sam
dir_root = 'C:\Users\dketchum\Documents\Summer Research 2020\subj04.zip'; % Declan - update with your file location and uncomment
%dir_root = 'C:\Users\saman\Documents\MATLAB\EMGdata\'; % Rishita - update with your file location and uncomment
%dir_root = 'C:\Users\saman\Documents\MATLAB\EMGdata\'; % Maya - update with your file location and uncomment

subjectnumbers = 4; %Can be a vector with multiple numbers or just an integer
sessionnumbers = 1:3; %Which sessions to include (usually 1-3)
movementnumbers = 1:13; %which movement to load
repetitionnumbers = 1:6; %Which repetitions to include
includeglove = true; %True if you want to include the glove data
triallengthsec = 3.5; % Trial length to keep in seconds; Note: data are not all the same length. You will get an error if this value is longer than the shortest length

% The experimental data are split into folders per subject, 
% each filename has the format detop_exp01_subjAA_SessB_CC_DD.mat
% AA: subject number (1–25)
% B: session(1–3)
% CC: movement (1–13)
% DD: repetition number (1–6)

% Load the selected data into a file structure that mimics EEGlab
% ALLEEG contains the data for all subjects, EEG is the data and info for
% one suject
% To match EEGLAB, data dimensions are channel, time, trials; 
% data is the EMG data, glove data gets stored as glovedata


for s=1:length(subjectnumbers)
    dir_subj = strcat(dir_root,'subj',num2str(subjectnumbers(s),'%02.f'),'\');
    ALLEEG{s} = struct('subject',strcat('subj',num2str(subjectnumbers(s),'%02.f')));
    
    tn = 1; % Trial number
    for se = sessionnumbers
       for mn = movementnumbers
           for rn = repetitionnumbers
               try
               % Load the data from .mat file
               sdf = load(strcat(dir_subj,'detop_exp01_subj', num2str(subjectnumbers(s),'%02.f'),'_Sess',num2str(se),'_', num2str(mn,'%02.f'),'_', num2str(rn,'%02.f')));
               catch
                   disp(strcat('Could not loac: _ ', dir_subj,'detop_exp01_subj', num2str(subjectnumbers(s),'%02.f'),'_Sess',num2str(se),'_', num2str(mn,'%02.f'),'_', num2str(rn,'%02.f')))
               end
               if tn == 1 %Things that should be the same for all trials
                ALLEEG{s}.srate = sdf.fs_emg;
                ALLEEG{s}.chanlocs = struct('labels',sdf.channels_emg); %SWM, fix to not be char and to be one per label not all in one
               end
               ALLEEG{s}.data(:,:,tn) = sdf.emg(:,1:(sdf.fs_emg*triallengthsec));
               ALLEEG{s}.triallabels(tn).session = se;
               ALLEEG{s}.triallabels(tn).repetition = rn;
               ALLEEG{s}.speed{tn} = sdf.speed;
               ALLEEG{s}.movement{tn} = sdf.movement;
%                ALLEEG{s}.triallabels(tn).speed = sdf.speed;
%                ALLEEG{s}.triallabels(tn).movement = sdf.movement;
               if includeglove
                   ALLEEG{s}.glovedata(:,:,tn) = sdf.glove(:,1:(sdf.fs_glove*triallengthsec));
                   if tn==1
                       ALLEEG{s}.srate_glove = sdf.fs_glove;
                       ALLEEG{s}.channels_glove = sdf.channels_glove;
                   end
               end
               
               tn = tn+1; %Increment the trial number
           end
       end
   end
   ALLEEG{s}.speed = categorical(ALLEEG{s}.speed); 
   ALLEEG{s}.movement = categorical(ALLEEG{s}.movement);
end
=======
% These scripts can help you load data from multiple .mat files provided in
% the SEEDs data base.

%TODO: add in option to save a file with all subjects

% This settings help you load your specific data.

% This is the full file path for the folder that contains the subj* folder
dir_root = 'C:\Users\saman\Documents\MATLAB\EMGdata\'; %Must end in slash, this one is for Sam
%dir_root = 'C:\Users\saman\Documents\MATLAB\EMGdata\'; % Declan - update with your file location and uncomment
%dir_root = 'C:\Users\saman\Documents\MATLAB\EMGdata\'; % Rishita - update with your file location and uncomment
%dir_root = 'C:\Users\saman\Documents\MATLAB\EMGdata\'; % Maya - update with your file location and uncomment

% Directory to save the output file
dir_output =  'C:\Users\saman\Documents\MATLAB\EMGdata\RawSubj\'; %Must end in slash, this one is for Sam
fname_output = '-alldata'; % Tag for file name (follows subject name)
save_output = true; % True for save the output as a .mat file

subjectnumbers = 1; %Can be a vector with multiple numbers or just an integer
sessionnumbers = 1:3; %Which sessions to include (usually 1-3)
movementnumbers = 1:13; %which movement to load
repetitionnumbers = 1:6; %Which repetitions to include
includeglove = true; %True if you want to include the glove data
triallengthsec = 4.0; % Trial length to keep in seconds; Note: data are not all the same length. You will get an error if this value is longer than the shortest length

% The experimental data are split into folders per subject, 
% each filename has the format detop_exp01_subjAA_SessB_CC_DD.mat
% AA: subject number (1–25)
% B: session(1–3)
% CC: movement (1–13)
% DD: repetition number (1–6)

% Load the selected data into a file structure that mimics EEGlab
% ALLEEG contains the data for all subjects, EEG is the data and info for
% one suject
% To match EEGLAB, data dimensions are channel, time, trials; 
% data is the EMG data, glove data gets stored as glovedata


% Actually load the data into a data structure
for s=1:length(subjectnumbers)
    dir_subj = strcat(dir_root,'subj',num2str(subjectnumbers(s),'%02.f'),'\');
    ALLEEG{s} = struct('subject',strcat('subj',num2str(subjectnumbers(s),'%02.f')));
    
    tn = 1; % Trial number
    for se = sessionnumbers
       for mn = movementnumbers
           for rn = repetitionnumbers
               try
               % Load the data from .mat file
               sdf = load(strcat(dir_subj,'detop_exp01_subj', num2str(subjectnumbers(s),'%02.f'),'_Sess',num2str(se),'_', num2str(mn,'%02.f'),'_', num2str(rn,'%02.f')));
               catch
                   disp(strcat('Could not loac: _ ', dir_subj,'detop_exp01_subj', num2str(subjectnumbers(s),'%02.f'),'_Sess',num2str(se),'_', num2str(mn,'%02.f'),'_', num2str(rn,'%02.f')))
               end
               if tn == 1 %Things that should be the same for all trials
                ALLEEG{s}.srate = sdf.fs_emg;
                ALLEEG{s}.chanlocs = struct('labels',sdf.channels_emg); %SWM, fix to not be char and to be one per label not all in one
                ALLEEG{s}.times = 0:(1000/ALLEEG{s}.srate):((triallengthsec*1000)-(1000/ALLEEG{s}.srate));
               end
               ALLEEG{s}.data(:,:,tn) = sdf.emg(:,1:(sdf.fs_emg*triallengthsec));
               ALLEEG{s}.triallabels(tn).session = se;
               ALLEEG{s}.triallabels(tn).repetition = rn;
               ALLEEG{s}.speed{tn} = sdf.speed;
               ALLEEG{s}.movement{tn} = sdf.movement;
%                ALLEEG{s}.triallabels(tn).speed = sdf.speed;
%                ALLEEG{s}.triallabels(tn).movement = sdf.movement;
               if includeglove
                   ALLEEG{s}.glovedata(:,:,tn) = sdf.glove(:,1:(sdf.fs_glove*triallengthsec));
                   if tn==1
                       ALLEEG{s}.srate_glove = sdf.fs_glove;
                       ALLEEG{s}.channels_glove = sdf.channels_glove;
                   end
               end
               ALLEEG{s}.trials = tn;
               tn = tn+1; %Increment the trial number
           end
       end
   end
   ALLEEG{s}.speed = categorical(ALLEEG{s}.speed); 
   ALLEEG{s}.movement = categorical(ALLEEG{s}.movement);
   
   if save_output
       EEG = ALLEEG{s};
       save(strcat(dir_output,'subj',num2str(subjectnumbers(s),'%02.f'),fname_output,'.mat'),'EEG');
       disp(strcat('Saving subj',num2str(subjectnumbers(s),'%02.f')))
   end
end
