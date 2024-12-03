This code is shared as a reference rather than a finished product for running your files automatically. You can follow the instructions below to tweak my scripts for your use.

Directions:
1. Download my codes for running VoiceSauce and put them in your VoiceSauce folder.
2. Download Praat if you haven't already. I'm using only Praat methods to extract pitch and formants.
3. In func_PraatPitch.m and func_PraatFormants.m, go to the line where it declares praat_path. Change this directory to your Praat path.
  If using LINUX, you'll have to add conditionals for setting the Praat path (use isunix() in MATLAB). 
5. In run_voicesauce_remote.m, go to the line with cd PATH. Change this path to your path to VoiceSauce folder.
  For running in a single folder, run this command in MATLAB: run_voicesauce_remote(AUDIOFOLDER);
    OR in the command line: matlab -nojvm -nodisplay -r "run_voicesauce_remote(AUDIOFOLDER); exit;"
6. You can reference run_voicesauce_all_remote.m to see how I looped over different file directories & set different F0 parameters based on gender.
