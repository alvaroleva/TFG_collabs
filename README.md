# **TFG |AI-based classification of symptomatic subjects with Brugada Syndrome from ECG-derived Markers and clinical data**
## Barcelona, 06 de June de 2023.
### Author: Álvaro Leva Ligero. 

> Director/s: Elena Arbelo, Flavio Palmieri, Pedro Gomis
--------
This repository includes all the Python scripts developed during the second phase of the project. It contains:
* **p01:** Load of ECG-derived biomarkers and merge with clinical data.
* **p02:** Data imputation and exploratory analysis. 
* **Model optimization and validation:** KNN, SVM, RF and XGBoost. 
**ABSTRACT**

Brugada Syndrome (BrS) is a hereditary disease linked to an increased risk of suffering malignant arrythmias that can lead to sudden cardiac death (SCD). With most of the patients remaining asymptomatic, the detection of the high-risk cases that require an implantable cardioverter-defibrillator (ICD) for prevention is crucial. However, risk stratification remains challenging in absence of reliable predictors to anticipate the first occurrence of fatal symptoms. In the search of novel methods to address this issue, this project aims to assess whether supervised classification models, trained with ECG-derived biomarkers and clinical data, can differentiate between symptomatic and asymptomatic BrS subjects. The study used 12-lead ECG 24h-Holter Recordings from 64 BrS subjects, both symptomatic (16%) and asymptomatic (84%). ECG signals were segmented into 3-minute intervals to reduce noise by signal-averaging, and several ECG-biomarkers were computed from the averaged beats. The resulting ECG-biomarkers were combined with clinical data to train and validate four supervised classification models: K-Nearest Neighbours (KNN), Support Vector Machine (SVM), Random Forest (RF), and Extreme Gradient Boosting (XGBoost). Confusion matrix analysis revealed the overall outstanding capabilities to detect asymptomatic patients (specificity > 80%) but the poor detection of symptomatic patients (sensitivity < 50%). Subsequently, AUC and sensitivity scores were used for cross-validation of models. As a result, XGBoost and RF gave the best performance (AUC = 0.888 and AUC = 0.907). Nevertheless, the poor classification of the symptomatic class was reflected in low sensitivities that did not exceed the maximum of 58.38% achieved by XGBoost. In conclusion, the project outcome cannot demonstrate the reliability of the supervised classification models to detect the symptomatic condition of BrS from the ECG-derived biomarkers and clinical data. However, it encourages the evaluation of these models on a larger cohort with balanced distribution of classes. 

**Keywords**: Brugada Syndrome, Sudden Cardiac Death, Risk stratification, ECG biomarkers, Supervised classification. 



