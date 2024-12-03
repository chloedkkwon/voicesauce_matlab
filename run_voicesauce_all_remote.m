function [] = run_voicesauce_all_remote()
dbstop if error

% Created by Chloe D. Kwon
% December 3, 2024
% Runs VoiceSauce by looping over audio files in fd_audio.
% 1. Change your path variables below based on your folder structure
% 2. If you don't want to specify the grid/output folder, comment out fd_grid & fd_out
% Then change the last function to run_voicesauce_remote(fd_audio);
% You'll have to modify run_voicesauce_remote.m to run files without
% textgrids

%Change this part based on your folder structure
path_expf = '/home/dk837/dissertation/experiment_files'; % this is the folder with all my data files 
path_procf = '/home/dk837/dissertation/processing_files'; % this is the folder with subject IDs

expIDs = cellstr(readlines(fullfile(path_procf, 'corrected.txt'))); % list of subject IDs to loop over

% These are NOT default parameter setting in Praat. Please edit it based on
% your data. 
V = struct(); % set params
V.frameshift = 1; % 1 ms step size
V.windowsize = 25; % 25 ms window
V.preemphasis = 0.96; 
V.lpcOrder = 12; 
V.maxstrF0 = 500; 
V.minstrF0 = 40; 
V.maxF0 = 500; 
V.minF0 = 40; 
V.maxstrdur = 10; 
V.tbuffer = 25; 
V.TextgridIgnoreList = '''SIL"'; 
V.TextgridTierNumber = 1; 
V.frame_precision = 1; 
V.F0Praatmax = 500; 
V.F0Praatmin = 40; 
V.F0PraatVoiceThreshold= 0.800;
V.F0PraatOctaveJumpCost= 0.700;
V.F0PraatSilenceThreshold= 0.300;
V.F0PraatOctaveCost= 0.0100;
V.F0PraatVoicedUnvoicedCost= 0.1400;
V.F0PraatKillOctaveJumps= 0;
V.F0PraatSmooth= 0;
V.F0PraatSmoothingBandwidth= 5;
V.F0PraatInterpolate= 0;
V.F0Praatmethod= 'cc'; %cross correlation
V.FormantsPraatMaxFormantFreq= 6000;
V.FormantsPraatNumFormants = 4;
V.SHRmin = 40;
V.SHRmax = 500; 
V.SHRThreshold = 0.4;

for i=1:length(expIDs)
    expID = expIDs{i}; 
    subj = expID(1:3); 

    fd_audio = fullfile(path_expf, expID, [subj '_audio']); %audio folder
    fd_grid = fullfile(path_expf, expID, [subj '_grid_corrected']); %grid folder
    fd_output = fullfile(path_expf, expID, [subj '_voice']); %output folder
    
    path_param = fullfile(fd_output, ['_params_voice_' subj '.mat']); 

    gend = subj(1); 
    if strcmp(gend, 'F') % Different parameters for female speakers because their F0 range is different; this helps not detecting bad pitch candidates
        V.F0Praatmax = 400; 
        V.F0Praatmin = 200; 
    else
        V.F0Praatmax = 250;
        V.F0Praatmin = 50; 
    end

    save(path_param, 'V')

    run_voicesauce_remote(fd_audio, 'fd_grid', fd_grid, 'fd_output', fd_output, ...
        'path_param', path_param); 
end
end