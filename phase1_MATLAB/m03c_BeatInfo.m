% Preliminary step needed to arrange the beats in the final biomarker matrix

% Generate an 'BeatsInfo.mat' file that contains an struct with: 
% - Total number of beats for each BH (Nbeats - double)
% - Overall position of the first beat of each BH (PosBeats - double).
% - Total number of Beats from all BHs (TotBeats - double). 
% - Saved beat indexes, to ease the iteration of the new saved beats,
%   the ones that remain from the SAV step. (BeatNewIdx - cell)
%
%   Author A.Leva (2023)
%   adaptation from L.Tortosa (2022).

clear;

total_pat = [1:40, 42:45,47:53,77:79,86,88,90:92,94,96,97,98,99,100:111]; %BH patient numbers
Nbeats = zeros(length(total_pat),2); % number of beats for each patient
PosBeats = zeros(length(total_pat),2); % first beat position in the overall sequence of beats from all patients
TotBeats = 0; % number of beats of the overall cohort

BeatNewIdx = cell(length(total_pat),2); %initialize the final structure

for iPat = 1:length(total_pat) %patient count
    n_pat = total_pat(iPat);  %BH patient numbers

    patBH_path = sprintf('D:\\alvaro\\results_data\\3min_avBeats\\pat_BH%d', n_pat);
    dir_info = dir(patBH_path);
    beat_files = dir_info(contains({dir_info.name}, 'beat.mat')); %selects only those file names that contain 'beat'

    %First column for BH number
    Nbeats(iPat, 1) = n_pat;
    PosBeats(iPat, 1) = n_pat;

    Nbeats(iPat, 2) = length(beat_files); %number of beats for each BH patient
    TotBeats = TotBeats + Nbeats(iPat, 2); %Cumulative sum of beats
    
    %Position of the first beat when putting all sequentially
    if n_pat>1 %%Position of the rest of beats
    
    PosBeats(iPat,2) = TotBeats - Nbeats(iPat,2) + 1;
    
    else %First beat position
    
    PosBeats(iPat,2) = 1;
        
    end

    %BEAT NEW INDEX DATA: to ease the iteration of the new saved beats
    %(the ones accepted from the SAV step)

    BeatNewIdx{iPat,1} = n_pat; %1st col: for BH number

    %2nd col: Array with the segment numbers from the saved beats 'ECG_pat_X_beat.mat'
    beat_idx = zeros(Nbeats(iPat,2),1);
    for i = 1:Nbeats(iPat,2) %iterate each beat file
        beat_file_name = split(beat_files(i).name, '_'); %extract splitted file_name
        beat_idx(i) = str2double(beat_file_name{3}); %save the beat idx
    end

     BeatNewIdx{iPat,2} = sort(beat_idx); %2nd col: array with beat indexes

end

%Generate a struct with the beat info
cd('D:\\alvaro\\results_data')
save BeatsInfo Nbeats PosBeats TotBeats BeatNewIdx