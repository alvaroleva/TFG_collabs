Álvaro Leva Ligero

# Phase 1: signal pre-processing and ECG-biomarker extraction

<img align="left" src="https://img.shields.io/badge/ TFG-phase1-yellow"><img align="left" src="https://img.shields.io/badge/Development environment -MATLAB-blue"></br>

In this first phase, all the algorithms developed to pass from the initial 24h ECG signal (ISHNE format) to the final table containing the 12-lead ECG biomarkers are described.

> The open-source software [ECG-kit](http://marianux.github.io/ecg-kit/) is used. 


## Contents
- [Reading and splitting the 24h signal](#reading-and-splitting-the-24h-signal)
- [Signal averaging](#signal-averaging)
- [Beat delineation](#beat-delineation)
    - [Add 1 second](#add-1-second)
    - [Delineation](#delineation)
    - [Beat arrangament information](#beat-arrangament-information)
- [12lead ECG biomarker calculation](#12lead-ecg-biomarker-calculation)
- [Folder structure](#folder-structure)

## Reading and splitting the 24h signal

In this first script ``m01_ishne2segments_3min.m``, the original 24h Holter recordings in *ISHNE* format are readed using ``.read_signal`` from *ECG-kit*. This method alows to delimit the interval to read. In this case, sliding windows of 3-min are defined for the subsequent step of signal averaging. 

Additionally, the signal is converted from ADC units to microvolts using the ``.gain``, extracted from the original ISHNE header. Furthermore, the baseline (``.adczero``) is removed. 

Finally, the algorithm iterates through all the *BH subjects* saving their 24h ECG signal in 3-min segments. Output signals include all 12-leads. 

> Output file: ``ECG_<BH number>_<segment_number>.mat``



## Signal averaging
    
Once the 24h ECG signal is segmented in 3-min intervals, signal averaging is applied to each segment aiming to obtain a set of average beats with reduced noise. In our case the implemented algorithm can be found in ``m02_SignalAveraging.m``. In our approach,  ensemble averaging is complemented with shift correction and rejection conditions to avoid considering abnormally misaligned beats in the ensemble. The following "flow-chart-like" scheme describes how the algotithm works. Notice that the implemented algorithm is based on 5 nested for-loops (blue), two quality control conditions derived from Threshold 1 and Threshold 2 (yellow), the generation of 3 auxiliar files (purple) and a set of processes and operations (white boxes).

    
<p align="center">
<img src = "assets/SAV_flowchartlike.png" width = 70%>
</p>

<p align="center">
<i> Fig.1 - Descriptive scheme of signal averaging workflow. </i>
</p>

    
> Output file: ``ECG_<BH number>_<segment_number>_beat.mat``
    Auxiliary file: ``ECG_<BH number>_<segment_number>_filt.mat``

    
**NOTE:** Only the files derived from the **accepted** average beats are saved for further processing. The rest are deleted. From now on, the files containing ``ECG_<BH number>_<segment_number>_**beat**.mat`` are the ones used. 

## Beat delineation
In order to compute the 12-lead ECG biomarkers for each average beat, the signals must be delineated to detect the reference points. 
### Add 1 second 
After the noise reduction pre-processing, all the obtained 1 second beats were delineated in order to extract the ECG fiducial points of interest. The delineation process using the ‘wavedet’ algorithm from *ECGkit*, required a preliminary step consisting in the addition of an isoelectric segment of 1 second before every beat. The reason for this, is that the ECGkit delineator starts the detection from 1 second. Therefore, without the addition of an extra segment the beat would be ignored. A simple script adds 1 extra second to each average beat ``m03a_add_1sec_before_delin.m``

## 12lead ECG biomarker calculation
    
## Folder structure

