% Ensemble signal averaging of the 3-min ECG segments
% before the averaging itself, shift correction based on
% cross-correlation with a template beat is conducted. Two rejection
% conditions are set based to reject those abnormally misaligned beats.
% please be aware of the large execution time.

% Author: A.Leva with support of Flavio Palmieri
clc;close all;clear;

N = 1000; %sample size of the final averaged beats
for n_pat = [1:40, 42:45,47:53,77:79,86,88,90,92,94,96,97,98,99,100:110] %BH patient numbers
    
    cd(sprintf('D:\\alvaro\\3min_seg\\pat_BH%d',n_pat)); %directory with the 3 min segments
   
    for i = 1:479 %iterate each 3 min segment
        cd(sprintf('D:\\alvaro\\3min_seg\\pat_BH%d',n_pat)); %directory with the 3 min segments

        ECG = ECGwrapper('recording_name',sprintf('ECG_%d_%d.mat',n_pat,i)); %load the 3 min segment
        header = ECG.ECG_header; % extract the header
        fs = ECG.ECG_header.freq; %extract the sampling frequency
        s = ECG.read_signal(1,ECG.ECG_header.nsamp); %read the signal
        leads = {'I','II','III','aVR','aVL','aVF', 'V1', 'V2', 'V3', 'V4','V5','V6'}; %lead labels
    
        % Reference delimitate individual beats 
        % Detect QRS on raw signal: R wave peak of raw ECG
        ECG.ECGtaskHandle = 'QRS_detection';
        ECG.ECGtaskHandle.detectors = 'wavedet'; % R peak detection
        ECG.Run;
        ecgNameDect = sprintf('D:\\ECG_%d_%d_QRS_detection.mat', n_pat, i);
        load(ecgNameDect) %load the QRS peaks
        
        %Preliminary step, filtering needed ONLY to accurately define the shift threshold:
        %High Pass Filter
        cd("C:\\Users\\USER\\Desktop\\Brugada\\codes");
        sig = ECG_filt(s, fs, 0.6, 40); % flow = 0.6 Hz / fhigh = 40 Hz
        ecgNameFilt = sprintf('D:\\alvaro\\3min_seg\\pat_BH%d\\ECG_%d_%d_filt.mat',n_pat, n_pat, i); %file name of the filtered signal
        save(ecgNameFilt,"sig", "header"); %save the filtered signal
        
        % ECG delineation of the filtered signal to extract 
        % threshold 1 = average QRS duration
        ECGw_filt = ECGwrapper('recording_name',ecgNameFilt);
        ECGw_filt.ECGtaskHandle = 'ECG_delineation';
        ECGw_filt.Run;
        ecgNameDelin_filt = sprintf('D:\\alvaro\\3min_seg\\pat_BH%d\\ECG_%d_%d_filt_ECG_delineation.mat',n_pat, n_pat, i);
        load(ecgNameDelin_filt)
        w = wavedet;

        %SIGNAL AVERAGING WITH CORRECTED SHIFT
        xkl = []; %initial ensemble
        Nb=[]; %number of beats
        signal = []; %final signal

        for iDer=1:12 %iterate each lead
            eval(['tw = wavedet_' leads{iDer} '.time;']) %extract the Rpeak times (tw) from each lead
            Nb(iDer)=length(tw); %number of beats for the header

            for iQRS=1:(length(tw)-5) %iterate each beat
                nint = fs;    % A window of 1 second is chosen around QRSpeaks even if that includes part of the following beat
                xkl(iQRS,:)= s(tw(iQRS)-399:tw(iQRS)+nint-400,iDer)'; %save each individual beat in the ensemble
            end

            Template = mean(xkl); % Compute a refence beat

            %SHIFT CORRECTION
            ECGibeat_NEW=[]; %initialize the new ensemble for the corrected beats
            
            % initialize QRSon and QRSoff arrays to ultimately compute the
            % shift threshold as average QRS duration of the 3min seg
            QRSon = []; 
            QRSoff = [];
            th = [];

            reject = []; %intitialize the array to store rejected beats

            %COMPUTE THE SHIFT THRESHOLD TO REJECT THE MISALIGNED BEATS
            %QRSon
            if ~isempty(eval(['w.' leads{iDer} '.QRSon;']))
                eval(['QRSon = w.' leads{iDer} '.QRSon;'])
            else
                QRSon = [];
            end

            %QRSoff
            if ~isempty(eval(['w.' leads{iDer} '.QRSoff;']))
                eval(['QRSoff = w.' leads{iDer} '.QRSoff;'])
            else
                QRSoff = [];
            end
            
            % assess if QRSmean can be computed
            if ~isempty(QRSon) && ~isempty(QRSoff) 
                RM = union(find(isnan(QRSon) == 1), find(isnan(QRSoff) == 1));
                QRSon(RM) = [];
                QRSoff(RM) = [];
                if ~isempty(QRSon) && ~isempty(QRSoff)
                    th = round(median(QRSoff - QRSon)); %compute th as the average QRS duration
                else
                    th = 120 % if not QRS duration as the maximum normal value
                end
            else
                th = 120; % if not QRS duration as the maximum normal value
            end

            %SHIFT-BASED BEAT ALIGNMENT
            for ilatido =1: size(xkl,1) %iterate each beat
                Beat2=detrend(xkl(ilatido,:)); %detrended beat
                [c,lags] = xcorr(Template,Beat2); %correlation beat-template
                [~,n]=max(c); % find the maximum value of the  cross-correlation
                Shift=lags(n); % save the lag related with the maximum value previously found

                if abs(Shift)<th % if the shift is lower than QRS average duration
                    %forward shift correction
                    if sign(Shift)==1
                        c = Beat2(1);
                        v = c(ones(abs(Shift), 1));
                        newBeat2=[v' Beat2(1:end-Shift)];
                        %backward shift correction
                    elseif sign(Shift)==-1
                        c = Beat2(end);
                        v = c(ones(abs(Shift), 1));
                        newBeat2=[Beat2(1+abs(Shift):end) v'];
                        %no shift
                    else
                        newBeat2=Beat2;
                    end
                    %apply the correspondig correction
                    ECGibeat_NEW=[ECGibeat_NEW; newBeat2];

                else %if the shift exceeds the threshold reject the beat
                    reject = [reject; Beat2]; 
                end

            end

            %SINGAL AVERAGING of the corrected ensemble 
            sig_dt = detrend(median(ECGibeat_NEW));
            signal(:,iDer) = sig_dt;
        end

        % Rejection condition 2 to assess valid 3min segments based on the proportion of rejected beats
        if ( size(reject,1) < round(0.3*size(xkl,1)) ) %only save those segments with less than 30% of rejections
            
            header.nsamp=N; %Redefine the number of samples. Signal has been converted from 3 mins (180000samples) to 1sec (1000samples). 
            ecgNameOUT = sprintf('D:\\alvaro\\results_data\\3min_avBeats\\pat_BH%d\\ECG_%d_%d_beat',n_pat, n_pat, i);
            save(ecgNameOUT, 'signal', 'header', 'Nb')

            %Save appart filtered segments for the further QRSdetection to
            %compute RRmean. 
            movefile(sprintf('D:\\alvaro\\3min_seg\\pat_BH%d\\ECG_%d_%d_filt.mat',n_pat, n_pat,i),sprintf('D:\\alvaro\\results_data\\3min_filtered\\fpat_BH%d', n_pat))

        else
            delete(ecgNameFilt) %d
        end

        delete(ecgNameDect)
        delete(ecgNameDelin_filt)
    end
end