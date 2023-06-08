# **TFG |AI-based classification of symptomatic subjects with Brugada Syndrome from ECG-derived Markers and clinical data**
**Barcelona, 06 de June de 2023.**

**Author: Álvaro Leva Ligero.**

**Director/s: Elena Arbelo, Flavio Palmieri**

---

## Contents
This repository includes all the scripts developed during the project. 

* **Phase 1 (MATLAB): Signal pre-processing and extraction of ECG-derived biomarkers**
  * Read ISHNE signal and 3min-segmentation of the 24h-Holter recording. ``m01_ishne2segments_3min.m`` 
  * Signal averaging ``m02_SignalAveraging.m``
  * Beat delineation ``m03b_BeatDelineation.m``
  * 12-lead ECG-biomarkers computation ``m04b_BiomarkerCalculation_12leads.m``
  <br>
  
  > *Auxiliary scripts:* ``m03a_add_1sec_before_delin.m``, ``m04a_RRmean_4EachLead.m``
  
* **Phase 2 (Python): Evaluation of supervised classification models in the task of differentiation of the symptomatic and asymptomatic BrS condition** 
  * Data cleaning and homogeneization.``p01_LoadMergeSumm_Data.ipynb``
  * First exploratory analysis and Data imputation. ``p02_FeatureSelection_DataVisualization.ipynb``
  * Optimization and evaluation of different classifiers: KNN, SVM, RF and XGBoost. ``KNN.ipynb`` , ``RandomForest.ipynb``, ...
  
 ## Abstract

Brugada Syndrome (BrS) is a hereditary disease linked to an increased risk of suffering malignant arrythmias that can lead to sudden cardiac death (SCD). With most of the patients remaining asymptomatic, the detection of the high-risk cases that require an implantable cardioverter-defibrillator (ICD) for prevention is crucial. However, risk stratification remains challenging in absence of reliable predictors to anticipate the first occurrence of fatal symptoms. In the search of novel methods to address this issue, this project aims to assess whether supervised classification models, trained with ECG-derived biomarkers and clinical data, can differentiate between symptomatic and asymptomatic BrS subjects. The study used 12-lead ECG 24h-Holter Recordings from 64 BrS subjects, both symptomatic (16%) and asymptomatic (84%). ECG signals were segmented into 3-minute intervals to reduce noise by signal-averaging, and several ECG-biomarkers were computed from the averaged beats. The resulting ECG-biomarkers were combined with clinical data to train and validate four supervised classification models: K-Nearest Neighbours (KNN), Support Vector Machine (SVM), Random Forest (RF), and Extreme Gradient Boosting (XGBoost). Confusion matrix analysis revealed the overall outstanding capabilities to detect asymptomatic patients (specificity > 80%) but the poor detection of symptomatic patients (sensitivity < 50%). Subsequently, AUC and sensitivity scores were used for cross-validation of models. As a result, XGBoost and RF gave the best performance (AUC = 0.888 and AUC = 0.907). Nevertheless, the poor classification of the symptomatic class was reflected in low sensitivities that did not exceed the maximum of 58.38% achieved by XGBoost. In conclusion, the project outcome cannot demonstrate the reliability of the supervised classification models to detect the symptomatic condition of BrS from the ECG-derived biomarkers and clinical data. However, it encourages the evaluation of these models on a larger cohort with balanced distribution of classes. 

**Keywords**: Brugada Syndrome, Sudden Cardiac Death, Risk stratification, ECG biomarkers, Supervised classification. 



