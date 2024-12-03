1. Download my codes for running VoiceSauce and put it in your VoiceSauce folder
2. Download Praat if you haven't already
5. In func_PraatPitch.m and func_PraatFormants.m, go to the line where it declares praat_path. Change this directory to your Praat path.
6. In run_voicesauce_remote.m, go to the line with cd PATH. Change this path to your path to VoiceSauce folder.
  For running in a single folder, run this command in MATLAB: run_voicesauce_remote(AUDIOFOLDER);
    OR in the command line: matlab -nojvm -nodisplay -r "run_voicesauce_remote(AUDIOFOLDER); exit;"
7. You can reference run_voicesauce_all_remote.m to see how I looped over different file directories & set different F0 parameters based on gender.
