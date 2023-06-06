% Process the ishne files with the holter ECG registers, saving them 
% in 3 min-segments as .mat files. Each patient have an associated "BH"
% number
% The free software ecg-kit is used:
% http://marianux.github.io/ecg-kit/
% Install and execute: InstallECGkit.m
% Most recent master version in: https://github.com/marianux/ecg-kit
% Author P.Gomis (2022)
% Adapted by A.Leva (2023)

% The file (patient, etc.) names should be modified to fit each case
clear;

for pat = [1:40, 42:45,47:53,77:79,86,88,90,92,94,96,97,98,99,100:110] %BH patient numbers

%Load the 24h ISHNE signal
cd(sprintf('D:\\alvaro\\3min_seg\\pat_BH%d',pat)) 
ECG = ECGwrapper('recording_name',sprintf('D:/BrugadaSignals/BH%04d',pat));

% Extract from the header
Nsamp=ECG.ECG_header.nsamp; %number of samples 
fs = ECG.ECG_header.freq; % sampling frequency

% Compute the number of 3-min segments
Nsegm = round(Nsamp/(fs*60*3));

% The first segment will begin after 60 seconds
ini = 60001;

for i = 0:Nsegm-2
    segm = i+1; %segment number
    fin = ini+3*60*fs-1; %sliding 3min index
    signal = ECG.read_signal(ini,fin);  % signals in 
    % Output in ADC units and int16 format
    signal = double(signal);   % signals in int16 --> float
    % Convert to Physical units (by default nV)
    gain = ECG.ECG_header.gain; % gain=4e-4 -> 1/2500 (Resolution = 2500 nV)
    baseline = ECG.ECG_header.adczero;
    [N,leads]=size(signal);
    
    for ii=1:leads
        signal(:,ii) = (signal(:,ii)-baseline(ii))/gain(ii); %baseline removal and unit conversion
    end
    
    % By default in nV (nanoVolts) --> mV (*1e-6)
    signal = signal.*1e-6;   % units in mV
    signal = detrend(signal);  % remove offset and working with all leads
    
    %Redefine the header
    header = ECG.ECG_header;
    header.nsamp = N;
    eval(['save ECG_' num2str(pat) '_' num2str(segm) ' signal header'])
    ini = fin + 1;
end
end