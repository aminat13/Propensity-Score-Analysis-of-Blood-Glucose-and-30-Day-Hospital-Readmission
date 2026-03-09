# Propensity-Score-Analysis-of-Blood-Glucose-and-30-Day-Hospital-Readmission

This repository contains an observational data analysis investigating the relationship between blood glucose status and 30-day hospital readmission among patients with diabetes.

The analysis was completed as part of the Advanced Data Analytics module in the MSc Technologies and Analytics in Precision Medicine.

Because observational hospital datasets are subject to confounding, this analysis applies propensity score methods and inverse probability of treatment weighting (IPTW) to estimate the association between blood glucose status and hospital readmission.

## Project Overview

Patients with elevated blood glucose levels during hospital admission may differ systematically from those with normal levels in terms of age, comorbidity burden, healthcare access, and disease severity.

These differences can introduce confounding, meaning crude comparisons between exposure groups may not reflect the true association between blood glucose and readmission risk.

To address this issue, the analysis compares three modelling approaches:

- Crude logistic regression
- Regression-adjusted logistic regression
- Propensity score weighted logistic regression (IPTW)

Propensity score methods estimate the probability of exposure given observed covariates and can be used to create a weighted pseudo-population where baseline characteristics are balanced between exposure groups. 

Research Question:

Is elevated blood glucose associated with an increased risk of 30-day hospital readmission among patients with diabetes after accounting for potential confounding variables? 

---

## Dataset

The dataset contains hospital inpatient encounters for individuals with diabetes and includes demographic and clinical variables relevant to readmission risk.

The data were loaded in R using the readmission dataset available in the readmission package. 

The dataset was restricted to patients with normal or high blood glucose levels, and observations with missing glucose measurements were removed.

After preprocessing:

- Original dataset size: 71,515 observations
- Final analytic dataset: 6,682 observations
- Approximately 90.7% of records were excluded due to missing or non-eligible exposure categories. 


| Variable | Description |
|---------|-------------|
| readmitted | 30-day hospital readmission status |
| blood_glucose | Blood glucose status (Normal or High) |
| age | Patient age group |
| sex | Biological sex |
| race | Patient race |
| admission_source | Source of hospital admission |
| insurer | Insurance type |
| duration | Length of hospital stay |
| n_medications | Number of medications prescribed |
| n_procedures | Number of medical procedures |
| n_diagnoses | Number of diagnoses recorded |
| n_previous_visits | Number of previous hospital visits |

## Methods

The analysis was conducted in R using the following packages:

- readmission
- ggplot2
- dplyr
- tidyverse
- broom
- forcats

The workflow consisted of five main stages.

### 1. Crude Association

A crude logistic regression model was fitted to estimate the association between blood glucose status and 30-day readmission.

| Exposure | Odds Ratio | 95% CI |
|---------|-----------:|-------|
| High vs Normal Glucose | 1.00 | 0.85 – 1.20 |

The crude estimate suggests no association between high blood glucose and readmission, although this may be influenced by confounding. 

### 2. Assessing Confounding

Baseline characteristics were compared between glucose exposure groups to identify potential confounders.

Variables examined included:

- Age
- Sex
- Race
- Admission source
- Insurer type
- Duration of stay
- Number of diagnoses
- Number of procedures
- Number of medications
- Number of previous visits

Several variables differed significantly between exposure groups, including race, age, admission source, and insurer type, suggesting the presence of confounding. 

### 3. Propensity Score Estimation

A propensity score model was fitted using logistic regression to estimate the probability of having high blood glucose conditional on observed covariates.

The propensity score represents:

- The probability of receiving the exposure given the observed patient characteristics.
- Propensity score distributions were summarised and visualised using density plots to assess overlap between exposure groups.
- Substantial overlap between groups suggests that valid comparisons between exposure groups are possible. 

### 4. IPTW Weighting

Inverse Probability of Treatment Weights (IPTW) were calculated as:

- 1 / PS for exposed individuals

- 1 / (1 − PS) for unexposed individuals

To reduce the influence of extreme observations, weights above the 99th percentile were truncated.

| Weights | Min | Median | Mean | Max |
|--------|----:|------:|----:|----:|
| IPTW before truncation | 1.09 | 1.95 | 2.00 | 7.50 |
| IPTW after truncation | 1.09 | 1.95 | 1.99 | 3.58 |

Truncation reduced extreme weights while preserving the overall distribution. 

### 5. Model Comparison

Three modelling approaches were compared.

| Model | Odds Ratio (High vs Normal Glucose) |
|------|------------------------------------:|
| Crude model | 1.00 |
| Regression-adjusted model | 1.03 |
| IPTW weighted model | 1.02 |

All models produced similar estimates close to one, indicating little evidence of an association between high blood glucose and 30-day hospital readmission. 

## Key Findings

The analysis demonstrated that:

- The crude association between blood glucose and readmission was approximately null
- Adjustment for potential confounders had minimal impact on the estimated association
- IPTW weighting produced similar estimates to regression adjustment
- There is little evidence that elevated blood glucose independently predicts 30-day readmission in this dataset

However, results should be interpreted cautiously due to:

- potential unmeasured confounding
- large reductions in sample size during preprocessing
- lack of formal covariate balance diagnostics.

## Running the Analysis

Clone the repository:
git clone https://github.com/aminat13/<repository-name>

Open the R workflow script:
scripts/assignment_5_workflow.R

Running the script will reproduce:

- data preprocessing
- crude logistic regression
- baseline comparison tables
- propensity score estimation
- IPTW weighting
- adjusted regression models

## Skills Demonstrated

This project demonstrates practical skills in:

- Causal inference with observational data
- Propensity score estimation
- Inverse probability of treatment weighting (IPTW)
- Confounding assessment
- Logistic regression modelling
- Data visualisation in R
- Reproducible statistical analysis workflows

## References

Evans, N. R., & Dhatariya, K. K. (2012).
Assessing the relationship between admission glucose levels, hospital stay, readmission and mortality.
Clinical Medicine. 

Everett, E., & Wisk, L. (2021).
Socioeconomic status, insurance coverage and adverse health outcomes in diabetes.
Journal of Diabetes Science and Technology. 

Kalyani, R. R., & Egan, J. M. (2013).
Diabetes and altered glucose metabolism with aging.
Endocrinology and Metabolism Clinics of North America. 

McDaniel, C. C., & Chou, C. (2022).
Clinical risk factors and social determinants of 30-day readmission among patients with diabetes.
Frontiers in Clinical Diabetes and Healthcare. 

Sanseverino, A. X. et al. (2025).
Risk factors associated with 30-day hospital readmission among older adults.
Revista Brasileira de Geriatria e Gerontologia. 

North Carolina Healthcare Association (2022).
Diabetes Readmissions Measure Description. 
