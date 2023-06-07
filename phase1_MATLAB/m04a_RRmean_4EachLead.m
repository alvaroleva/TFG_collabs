% The code calculates the RRpeak mean duration for each saved beat in the 12 leads (3min
% segments). The resulting times are in seconds. It uses the data from
% BeatsInfo.mat to iterate through the saved beats and to find its correct
% location in the resulting RRmean.mat final matrix.
% *Mean Execution Time / beat = 4.17 sec ->  Max Time / patient = (479*4.17) / 60 = 33.3 min
%
% Author A.Leva (2023)
clear;

load("D:\\alvaro\\results_data\\BeatsInfo.mat")
timeExec = zeros(TotBeats, 1);

RRmean = NaN(TotBeats, 13); %predefined zero matrix to save RRmean from each beat (for 12 leads). First column is for BH number

%[1:40, 42:45,47:53,77:79,86,88,90:92,94,96,97,98,99,100:104]

for n_pat = [1:40, 42:45,47:53,77:79,86,88,90,91,92,94,96,97,98,99,100:104] %BH patients numbers

    
    BHidx = find([BeatNewIdx{:,1}] == n_pat); %search the index for the corresponding BH in Nbeats first column
    beat_numbers = BeatNewIdx{BHidx, 2}'; %extract the saved beat numbers for that BH to iterate

    for iBeat = 1:length(beat_numbers) %iterate each beat file
        tic
        b = beat_numbers(iBeat); %beat segment name
        %A. QRS DETECTION of filtered 3 min segments from each beat
        
        ecgFiltName = sprintf('D:\\alvaro\\results_data\\3min_filtered\\fpat_BH%d\\ECG_%d_%d_filt.mat', n_pat, n_pat, b); % path to access the Filtered file name: "ECG_X_X_filt.mat";

        %Assess the QRSdetection is already done
        ecgDetName = sprintf('D:\\alvaro\\results_data\\QRSdetections\\dtpat_BH%d\\ECG_%d_%d_filt_QRS_detection.mat', n_pat, n_pat, b); %path to access the Detection file name: "ECG_X_X_filt_QRS_detection.mat"
        
        ECGfilt = ECGwrapper('recording_name', ecgFiltName); %load the filtered ecg segment wrapper
        if isfile(ecgDetName) == 1
            disp('Already Existing QRS Detection File | Loading...')
            load(ecgDetName) %If it exists load the file

        else %elsewhere, compute the QRS Detection
            ECGfilt.ECGtaskHandle = 'QRS_detection';
            ECGfilt.ECGtaskHandle.detectors = {'wavedet'}; % Método wavelet
            ECGfilt.Run;
            
            %Transfer the new QRSdetection file
            QRSdet_path = sprintf('D:\\alvaro\\results_data\\QRSdetections\\dtpat_BH%d\\ECG_%d_%d_filt_QRS_detection.mat', n_pat, n_pat, b);
            movefile(sprintf('D:\\alvaro\\results_data\\3min_filtered\\fpat_BH%d\\ECG_%d_%d_filt_QRS_detection.mat', n_pat, n_pat, b),  QRSdet_path) %move the detection file from the filtered folder to the Detection one
            
            load(ecgDetName) %Once generated load the file
        end

        %B. Perform the RRmean calculus for each lead
        %Index correspondence 
        ini_idx = PosBeats(BHidx, 2); %Position of the first BH beat in the final RR matrix
        nrow = (iBeat - 1) + ini_idx %Idx of each beat in the final RR matrix
        
        RRmean(nrow, 1) = n_pat; %the first colum corresponds to the patient BH number
        
        %Calculus
        fs = ECGfilt.ECG_header.freq; %extract the sampling frequency
        leads = {'I','II','III','aVR','aVL','aVF', 'V1', 'V2', 'V3', 'V4','V5','V6'}; %lead labels

        for iLead = 1:12 %iterate each lead
            eval(['tw = wavedet_' leads{iLead} '.time;']) %extract the Rpeak times (tw) from each lead
            RR = diff(tw); %compute the RR differences
            RR = RR/fs;    %convert RR to time units (sec)
            RRmean(nrow,iLead + 1) = mean(RR); %save the result (is saved in iLead + 1 cause the first column is BH)
        end

    %save the execution time / beat
    timeExec(iBeat) = toc;
    end
end

% disp(sprintf('Mean execution time / beat = %f4', mean(timeExec)))
% cd('D:\\alvaro\\results_data')
% save RRmean RRmean