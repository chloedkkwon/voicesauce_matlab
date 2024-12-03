function [] = run_voicesauce_remote(fd_audio, varargin)
dbstop if error

% Created by Chloe D. Kwon
% December 2, 2024
% Required input is fd_audio: your folder with audio files to analyze
% See comments for optional arguments


% Parse input arguments
p = inputParser; 
addRequired(p, 'fd_audio'); % required input argument - path to your audio folder

% Optional arguments
addParameter(p, 'fd_grid', 0); % grid folder
addParameter(p, 'fd_output', 0); % output folder
addParameter(p, 'path_param',0); % parameter file path
addParameter(p, 'params', {'F0', 'Formants', 'Harmonics', ...
    'Combinations', 'Energy', 'CPP', ...
    'HNR', 'SHR', 'SoE)'}, @iscell); 
% Use 'params' option to include a cell array of parameters to estimate
% e.g., run_voicesauce(fd_audio, fd_output, 'params', {'F0', '2K'})
% Make sure praat is in the working directory
% Choose parameter names from below list (if none is specified, all parameters will be estimated)
 % {'F0', 'Formants', 'Harmonics', ...
 %    'Combinations', 'Energy', 'CPP', ...
 %    'HNR', 'SHR', 'SoE)'}
 % If no parameters are chosen, then all parameters will be extracted

% Outputs FILENAME.mat files containing VoiceSauce measurements

parse(p, fd_audio, varargin{:}); 

if p.Results.path_param == 0
    V = p.Results; 
    [par, child] = fileparts(fd_audio); 
    V.path_param = fullfile(fd_audio, ['_params_voice_' child '.mat']); % parameter file path

    %Set parameters (These are Praat's default setting)
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
    V.F0PraatVoiceThreshold= 0.4500;
    V.F0PraatOctiveJumpCost= 0.3500;
    V.F0PraatSilenceThreshold= 0.0300;
    V.F0PraatOctaveCost= 0.0100;
    V.F0PraatOctaveJumpCost= 0.3500;
    V.F0PraatVoicedUnvoicedCost= 0.1400;
    V.F0PraatKillOctaveJumps= 0;
    V.F0PraatSmooth= 0;
    V.F0PraatSmoothingBandwidth= 5;
    V.F0PraatInterpolate= 0;
    V.F0Praatmethod= 'cc';
    V.FormantsPraatMaxFormantFreq= 6000;
    V.FormantsPraatNumFormants = 4;
    V.SHRmin = 40;
    V.SHRmax = 500; 
    V.SHRThreshold = 0.4;
    save(V.path_param, 'V')    
else
    load(p.Results.path_param, 'V'); 
    V.fd_audio = p.Results.fd_audio; 
    V.fd_grid = p.Results.fd_grid; 
    V.fd_output = p.Results.fd_output; 
    V.params = p.Results.params; 
    V.path_param = p.Results.path_param; 
end

if V.fd_grid == 0, V.fd_grid = V.fd_audio; end % get textgrid from the audio folder
if V.fd_output == 0, V.fd_output = V.fd_audio; end %save outcome in the audio folder
if ~exist(V.fd_output, 'dir'), mkdir(V.fd_output); end

%cd ~/Desktop/matlab_toolkit/VoiceSauce/
cd /home/matlab_utils/VoiceSauce % change this to your path to VoiceSauce

% Get list of audio files in the directory
audios = struct2table(dir(fullfile(fd_audio, '*.wav'))); 

% Loop through each audio file
for i=1:height(audios)
    aname = audios.name{i}; % filename w/ extension
    wavfile = fullfile(V.fd_audio, aname); 

    tname = [aname(1:end-3) 'TextGrid']; 
    textgridfile = fullfile(V.fd_grid, tname); 
    if ~exist(textgridfile, 'file'), continue; end

    matfile = fullfile(V.fd_output, [aname(1:end-3) 'mat']); % create .mat output file

    [y, Fs] = audioread(wavfile); 
    dur = length(y) / Fs; 
    % info = audioinfo(wavfile);
    % nbits = info.BitsPerSample;

    if Fs > 16000 % resample to 16kHz
        y = resample(y, 16000, Fs); 
        wavfile_new = [wavfile(1:end-4) '_16kHz.wav']; 
        Fs = 16000; 
        audiowrite(wavfile_new, y, Fs); 
    end

    data_len = floor(length(y) / Fs * 1000 / V.frameshift); 
    t = linspace(0, dur, data_len); 
    save(matfile, 't', 'data_len'); 

    % Get pitch for all params except HNR or Formant
    if any(~ismember(V.params, {'HNR', 'Formant'}))
        % Get F0 (Praat)
        [pF0, err] = func_PraatPitch(wavfile, V.frameshift/1000, V.frame_precision, ...
            V.F0Praatmin, V.F0Praatmax, V.F0PraatSilenceThreshold, V.F0PraatVoiceThreshold, ...
            V.F0PraatOctaveCost, V.F0PraatOctaveJumpCost, V.F0PraatVoicedUnvoicedCost, ...
            V.F0PraatKillOctaveJumps, V.F0PraatSmooth, V.F0PraatSmoothingBandwidth, ...
            V.F0PraatInterpolate, V.F0Praatmethod, data_len); 
        save(matfile, 'pF0', 'Fs', '-append')
    end
   
    if any(ismember(V.params, {'Formants', 'Combinations'}))
    % Get Formants and their bandwidths
        num_praat_formants = V.FormantsPraatNumFormants; 
        max_formant_freq = V.FormantsPraatMaxFormantFreq; 
    
        [pF1, pF2, pF3, pF4, pF5, pF6, pF7, pB1, pB2, pB3, pB4, pB5, pB6, pB7, err] = ...
            func_PraatFormants(wavfile,V.windowsize/1000, V.frameshift/1000, V.frame_precision, ...
            data_len, num_praat_formants, max_formant_freq);
        save(matfile, 'pF1', 'pF2', 'pF3', 'pF4', 'pB1', 'pB2', 'pB3', 'pB4', '-append');
    end

    if any(ismember(V.params, {'Harmonics', 'Combinations'}))
        % Get harmonics
        [H1, H2, H4, isComplete] = func_GetH1_H2_H4_kwon(y, Fs, pF0, V.frameshift, textgridfile); 
        save(matfile, 'H1', 'H2', 'H4', '-append');  
    
        % Get A1, A2, A3
        [A1, A2, A3] = func_GetA1A2A3_kwon(y, Fs, pF0, pF1, pF2, pF3, V.frameshift, textgridfile); 
        save(matfile, 'A1', 'A2', 'A3', '-append');
    
        % Get 2K
        [H2K, F2K, isComplete] = func_Get2K_kwon(y, Fs, pF0, V.frameshift, textgridfile); 
        save(matfile, 'H2K', 'F2K', '-append');
    
        % Get 5K
        [H5K, isComplete] = func_Get5K_kwon(y, Fs, pF0, V.frameshift, textgridfile); 
        save(matfile, 'H5K', '-append');
    end

    if any(ismember(V.params, 'Combinations'))
        % Combinations
        % Get H1*-H2* and H2*-H4*
        [H1H2c, H2H4c] = func_GetH1H2_H2H4(H1, H2, H4, Fs, pF0, pF1, pF2); % bandwidth method - formula 
        %[H1H2c, H2H4c] = func_GetH1H2_H2H4(H1, H2, H4, Fs, pF0, pF1, pF2, pB1, pB2, pB3); %
        %bandwidth method - estimate
        save(matfile, 'H1H2c', 'H2H4c', '-append');
    
        % Get H1*-A1*, H1*-A2*, H1*-A3*
        [H1A1c, H1A2c, H1A3c] = func_GetH1A1_H1A2_H1A3(H1, A1, A2, A3, Fs, pF0, pF1, pF2, pF3);
        save(matfile, 'H1A1c', 'H1A2c', 'H1A3c', '-append');
    
        % Get H4*-2K*
        [H42Kc] = func_GetH42K(H4, H2K,F2K, Fs, pF0, pF1, pF2, pF3);
        % [H42Kc] = func_GetH42K(matdata.H4, matdata.H2K, matdata.F2K, Fs, F0, F1, F2, F3, B1, B2, B3);
        save(matfile, 'H42Kc', '-append');
    
        % Get 2K*-5K
        [H2KH5Kc] = func_Get2K5K(H2K, F2K, H5K, Fs, pF0, pF1, pF2, pF3); 
        save(matfile, 'H2KH5Kc', '-append');
    end

    if any(ismember(V.params, 'Energy'))
        % Get Energy
        Energy = func_GetEnergy_kwon(y, pF0, Fs, V.frameshift); 
        save(matfile, 'Energy', '-append');
    end

    if any(ismember(V.params, 'CPP'))
        % Get CPP
        CPP = func_GetCPP_kwon(y, Fs, pF0, V.frameshift);
        save(matfile, 'CPP', '-append');
    end

    if any(ismember(V.params, 'HNR'))
        % Get HNR
        [HNR05, HNR15, HNR25, HNR35] = func_GetHNR_kwon(y, Fs, pF0, V.frameshift); 
        save(matfile, 'HNR05', 'HNR15', 'HNR25', 'HNR35', '-append');
    end

    if any(ismember(V.params, 'SHR'))
        % GET SHR
        [SHR, shrF0] = func_GetSHRP_kwon(y, Fs, data_len, V.frameshift, V.windowsize, ...
            V.SHRmin, V.SHRmax, V.SHRThreshold, V.frame_precision); 
        save(matfile, 'SHR', 'shrF0', '-append');
    end

    if any(ismember(V.params, 'SoE'))
        % Get epoch and SoE (excitation)
        [epoch, soe, z] = func_getSoE_kwon (y, data_len, Fs, 'whole', pF0, V.frameshift, V.windowsize); 
        save(matfile, 'epoch','soe', '-append');
    end

    if exist(wavfile_new, 'file'), delete(wavfile_new); end
end

[fd, current] = fileparts(fd_audio);
disp(['Finished processing: ' current])

end
