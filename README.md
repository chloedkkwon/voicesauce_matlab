These files are shared as a reference rather than a finished product to run your files automatically. You can follow the instructions below to customize for your use.

## Directions
1. Download the above codes in your VoiceSauce folder.
2. Download Praat if you haven't already. I'm using only Praat methods to extract pitch and formants.
3. In `func_PraatPitch.m` and `func_PraatFormants.m`, go to the line where it declares `praat_path.` Change this directory to your Praat path.
   - If your OS is LINUX, you'll have to add conditionals to set the Praat path (use `isunix()` in MATLAB). 
5. In `run_voicesauce_remote.m`, go to the line with `cd PATH`. Change this path to your path to the VoiceSauce folder.
   - For running in a single folder, run this command in MATLAB: `run_voicesauce_remote(AUDIOFOLDER);`
     OR in the command line: 
     ```bash
     matlab -nojvm -nodisplay -r "run_voicesauce_remote(AUDIOFOLDER); exit;"
     ```
6. You can reference `run_voicesauce_all_remote.m` to see how I looped over different file directories and set different F0 parameters based on gender.

---

### Citation
Adopted and modified codes originally from:  
[VoiceSauce](https://www.phonetics.ucla.edu/voicesauce/)  

   Shue, Y.-L., Keating, P., Vicenik, C., & Yu, K. (2011). *VoiceSauce: A program for voice analysis*. Proceedings of the International Congress of Phonetic Sciences (ICPhS), 1846–1849.
