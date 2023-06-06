%Performs beat delineation from the 2 second averaged beats
%Author A.Leva
clear;
for n_pat =  [1:40, 42:45,47:53,77:79,86,88,90,92,94,96,97,98,99,100:110] %BH numbers
    patBH_path = sprintf('D:\\alvaro\\results_data\\3min_avBeats\\pat_BH%d', n_pat); %directory with the SAV results
    
    %get "beat2" from the directory 
    dir_info = dir(patBH_path);
    beat2_files = dir_info(contains({dir_info.name}, 'beat2')); %selects only those file names that contain 'beat2' keyword
    Nbeats = length(beat2_files); %total number of beats
    
    signal = [];
    for i = 1:Nbeats %iterate each beat file
        tic
        cd(patBH_path);
        ecgBeat2Name = beat2_files(i).name; % file_name: "ECG_X_X_beat2.mat"
        ecgBeat2DelinName = ecgBeat2Name(1:end-4) + "_ECG_delineation.mat";
       
        %to avoid overunning check if is already an existing delineation
        if isfile(sprintf('D:\\alvaro\\results_data\\BeatDelineation\\dpat_BH%d\\',n_pat) + ecgBeat2DelinName) == 1
            load(sprintf('D:\\alvaro\\results_data\\BeatDelineation\\dpat_BH%d\\',n_pat) + ecgBeat2DelinName)
            disp('Already existing Delineation File') 
       
        else %if not, run the automated delineation
            %Load de 2sec beat
            file_2sec_name = char(sprintf("D:\\alvaro\\results_data\\3min_avBeats\\pat_BH%d\\",n_pat) + ecgBeat2Name);
            ECG = ECGwrapper('recording_name',file_2sec_name) ;
            %run delineation
            ECG.ECGtaskHandle = 'ECG_delineation'; 
            ECG.Run;
            movefile(sprintf("D:\\alvaro\\results_data\\3min_avBeats\\pat_BH%d\\",n_pat) + ecgBeat2DelinName, sprintf('D:\\alvaro\\results_data\\BeatDelineation\\dpat_BH%d\\',n_pat) + ecgBeat2DelinName)
        end
    end
end