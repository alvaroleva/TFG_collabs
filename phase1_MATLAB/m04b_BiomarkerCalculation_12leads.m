% 12-lead ECG-biomarker calculation: QT, QTc, J-point, J-point+60ms, 
% ST slope, PR, Absolute QRS area, Average QRS power, Late Potentials
% (RMS40, QRSd, LAS)
% Author: A.Leva (2023)

clear;
tic % assess execution time
leads = {'I','II','III','aVR','aVL','aVF', 'V1', 'V2', 'V3', 'V4','V5','V6'}; %lead labels

load('D:\alvaro\results_data\BeatsInfo.mat') %load BeatInfo for the number of beats, position and total BH beats.
load('D:\alvaro\results_data\\RRmean.mat') %load RRmean values, needed for further calculation.

%Predefine 12D Biomarker matrix (one dimension for each lead)
BiomarkerMatLead = zeros(TotBeats, 11, 12); % X Total beats x 11 Biomarkers x 12 leads
beat_pat_ID  = zeros(TotBeats, 1);      % column containing the BH number correspondence for each beat in rows

for n_pat = [1:40, 42:45,47:53,77:79,86,88,90:92,94,96,97,98,99,100:111] %BH patients number
    BHidx = find([BeatNewIdx{:,1}] == n_pat); %search the index for the corresponding BH in Nbeats first column
    beat_numbers = BeatNewIdx{BHidx, 2}'; %extract the saved beat numbers for each BHpatient
    
    for iBeat = 1:length(beat_numbers) %iterate each beat file
        
        b = beat_numbers(iBeat); %beat segment name
        %Index correspondence
        ini_idx = PosBeats(BHidx, 2); %Position of the first BH beat in the final RR matrix
        nrow = (iBeat - 1) + ini_idx %Idx of each beat in the final RR matrix

        beat_pat_ID(nrow) = n_pat; %save the BH patient ID of the beat

        % CALCULATION OF THE BIOMARKERS for each Lead --------------------------------------%
        
        %Load the beat2 signal
        ecgName2 = sprintf('D:\\alvaro\\results_data\\3min_avBeats\\pat_BH%d\\ECG_%d_%d_beat2.mat', n_pat, n_pat, b);
        ECG = ECGwrapper('recording_name',ecgName2);
        fs = ECG.ECG_header.freq;
        signal = ECG.read_signal(1,ECG.ECG_header.nsamp);
        
        
        %Load the Delineation of the beat
        ecgDelinName = sprintf('D:\\alvaro\\results_data\\BeatDelineation\\dpat_BH%d\\ECG_%d_%d_beat2_ECG_delineation.mat', n_pat, n_pat, b); %path to access the Delineation file name: "ECG_X_X_beat2_ECG_delineation.mat"
        load(ecgDelinName)

        w = wavedet; %save the delineation

        for iLead = 1:length(leads)
           
            %A. Extract Delineation Points:QRSon, QRSoff, QRSpeak, Toff, Pon
            
            % Check conditions, if a fiducial point is missing from
            % delineation assign the as NaN
            
            if ~isempty(eval(['w.' leads{iLead} '.QRSon']))
                eval(['QRSon = w.' leads{iLead} '.QRSon(end);'])  % QRS start
            else
                QRSon = NaN;
            end
            %   QRSoff
            if ~isempty(eval(['w.' leads{iLead} '.QRSoff']))
                eval(['QRSoff = w.' leads{iLead} '.QRSoff(end);'])  % End QRS
            else
                QRSoff = NaN;
            end
             %   QRSpeak
            if ~isempty(eval(['w.' leads{iLead} '.qrs']))
                eval(['qrsPeak = w.' leads{iLead} '.qrs(end);'])  % QRS peak
            else
                qrsPeak = NaN;
            end
            %   Toff
            if ~isempty(eval(['w.' leads{iLead} '.Toff']))
                eval(['Toff = w.' leads{iLead} '.Toff(end);'])  % End T
            else
                Toff = NaN;
            end

            %   Pon
            if ~isempty(eval(['w.' leads{iLead} '.Pon']))
                eval(['Pon = w.' leads{iLead} '.Pon(end);'])  % P start 
            else
                Pon = NaN;
            end
            
            %B. Perform Calculations 
            %%%QRS [Pavg, AreaQRSabs]
            if ~isnan(QRSon) && ~isnan(QRSoff)
                qrs = signal(QRSon:QRSoff, iLead);  % qrs signal values are separated
                QRSl = length(qrs);   % QRS length

                Pavg = 1/QRSl*sum(qrs.^2); %  Average potency of QRS (mV^2)
                AreaQRSabs = 1/fs*sum(abs(qrs))*1000; % Absolute QRS area(uV·s) UNITS??? mV·s

            else
                QRSl = NaN;
                Pavg = NaN;
                AreaQRSabs = NaN;
            end

            if ~isnan(QRSon) && ~isnan(Toff)
                % QT: goes from QRSon until Toff
                qt = Toff - QRSon +1;
                qt = qt/fs; % QT in seconds
            else
                qt = NaN;
            end
           
            % The particular RR value is selected for each beat
            RRi = RRmean(nrow,iLead+1); %RR contains BH column + 12leads RR columns
            
            if ~isnan(qt)
                QTc = qt/RRi.^(1/2);  % QTc_Barzett vector
                QTc = QTc*fs;     % Turned to miliseconds (ms)
            else
                QTc = NaN;
            end
            
            % Calcula linea de base (segPR) como la mediana del 
            % segmento ST desde 30 ms antes del QRSon hasta el QRSon
        
            if ~isnan(QRSon) && ~isnan(QRSoff)
                segPR = median(signal(QRSon-30:QRSon, iLead));
                signal(:,iLead) = signal(:,iLead) - segPR;  % se pone la linea IsoElect en 0
            end

            %%% ST = [ST_0, ST_60, ST_slope]
            % ST_0: ST level at 0 ms (J point)
            if  ~isnan(QRSoff)
                ST_0 = median(signal(QRSoff+(-2:2),iLead)); 
                ST_60 = median(signal(QRSoff+60+(-2:2),iLead));
                ST_slope = 1000*(ST_60 - ST_0)/60; % uV/ms 
            else
                ST_0 = NaN;
                ST_60 = NaN;
                ST_slope = NaN;
            end
    
            %PQ or PR interval (s)
            if ~isnan(QRSon) && ~isnan(Pon)
                % PQ: goes from Pon until QRSon
                pq = QRSon - Pon +1;
                pq = pq/fs; % PQ in seconds
            else
                pq = NaN;
            end

            %LEAD POTENTIALS calculation | Software developed by Pedro Gomis
            if ~isnan(QRSon) && ~isnan(QRSoff) && ~isnan(qrsPeak) 
                s_lead = signal(1001:end,iLead); % substracting 1000 samples added to signal for delineating
                QRSon   = QRSon - 1000;
                QRSoff   = QRSoff - 1000;
                qrsPeak = qrsPeak-1000;


                % Call latepot_i to compute Late Potential biomarkers over a single-lead
                cd('C:\\Users\\USER\\Desktop\\MATLAB_pipeline_LevaAlvaro') %latepot_i path
                [QRSd, RMS40, LAS] = latepot_i(s_lead, QRSon, QRSoff, qrsPeak); %By default: fs = 1000 Hz, fl = 40 Hz, fh = 250 Hz
            else
                QRSd  = NaN; %QRS duration (ms)
                RMS40 = NaN;
                LAS   = NaN;
            end     

            %Save the All the biomarker results in the matrix for each Lead
            BiomarkerMatLead(nrow,1,iLead) = Pavg;
            BiomarkerMatLead(nrow,2,iLead) = AreaQRSabs;
            BiomarkerMatLead(nrow,3,iLead) = qt;
            BiomarkerMatLead(nrow,4,iLead) = QTc;
            BiomarkerMatLead(nrow,5,iLead) = ST_0;
            BiomarkerMatLead(nrow,6,iLead) = ST_60;
            BiomarkerMatLead(nrow,7,iLead) = ST_slope;
            BiomarkerMatLead(nrow,8,iLead) = pq;
            BiomarkerMatLead(nrow,9,iLead) = QRSd;
            BiomarkerMatLead(nrow,10,iLead) = RMS40;
            BiomarkerMatLead(nrow,11,iLead) = LAS;
        end
    end
end

BiomarkerMat = reshape(BiomarkerMatLead, TotBeats, []); %transform 12D matrix into 2D --> biomarkers from diff leads will be transformed to consecutive columns
BiomarkerMat = horzcat(beat_pat_ID, BiomarkerMat);

%Format the final Matrix
BiomarkerMatFormat = num2cell(BiomarkerMat);
header_bmk = ["BH"];
for i = 1:length(leads)
    lead_str = string(leads(i));
    header_bmk = cellstr([header_bmk, "Pavg_" + lead_str,"AreaQRSabs_"+ lead_str, "qt_" + lead_str ,"QTc_"+ lead_str, "ST_0_"+ lead_str,"ST_60_" + lead_str,"ST_slope_" + lead_str, "PR_" + lead_str, "LP_QRSd_" + lead_str, "LP_RMS40_" + lead_str, "LP_LAS_" + lead_str]);
end
BiomarkerMatFormat = vertcat(header_bmk, BiomarkerMatFormat);
toc %assess execution time

% SAVE RESULTS
% cd('D:\\alvaro\\results_data')
% save BiomarkerMat BiomarkerMat
% save BiomarkerMatFormat BiomarkerMatFormat
% writecell(BiomarkerMatFormat, 'BiomarkerMatFormat_.xlsx')