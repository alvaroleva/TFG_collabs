% Preliminary script to allow further Delineation
%ECGkit starts automated delineation from 1 second --> this code adds an extra 1sec interval to 1sec averaged beats
clear;
for n_pat = [1:40, 42:45,47:53,77:79,86,88,90,92,94,96,97,98,99,100:110] %BH numbers
    patBH_path = sprintf('D:\\alvaro\\results_data\\3min_avBeats\\pat_BH%d', n_pat); %directory with the SAV results
    
    %get directory files
    dir_info = dir(patBH_path); 
    beat_files = dir_info(contains({dir_info.name}, 'beat')); %selects only those file names with the 'beat' SAV keyword
    Nbeats = length(beat_files); %total number of beats
    
    signal = []; 
    for i = 1:Nbeats %iterate each beat file
        cd(sprintf('D:\\alvaro\\results_data\\3min_avBeats\\pat_BH%d', n_pat));
        ecgBeatName = beat_files(i).name; % file_name: "ECG_X_X_beat.mat"
        load(ecgBeatName) %load the 1sec beat
       
        %Add 1 sec before extending the first sample
        s_1st = signal(1,:); %first sample of the signal
        signal = [s_1st.*ones(1000,12); signal];

        % redefine the header
        header.nsamp = 2000; %now 2 sec beat contains 2000 samples (1000Hz)

        %New file with the 2s signal "ECG_X_X_beat2.mat"
        ecgName2 = sprintf("D:\\alvaro\\results_data\\3min_avBeats\\pat_BH%d\\" + ecgBeatName(1:end-4) + "2.mat", n_pat);
        save(ecgName2, 'signal', 'header')
    end
end