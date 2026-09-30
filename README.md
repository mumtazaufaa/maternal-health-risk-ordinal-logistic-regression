# Maternal Health Risk Ordinal Logistic Regression

An ordinal logistic regression analysis of maternal health risk levels using physiological indicators from the UCI Maternal Health Risk dataset.

## Project Overview

This project analyzes three ordered maternal health risk categories — `low risk`, `mid risk`, and `high risk` — using ordinal logistic regression (`MASS::polr`) in R.

The analysis uses six physiological variables:

- Age
- Systolic Blood Pressure
- Diastolic Blood Pressure
- Blood Sugar
- Body Temperature
- Heart Rate

The workflow includes exploratory analysis, Tukey/IQR-based outlier clipping, ordinal response encoding, ordinal logistic regression, coefficient significance testing, odds-ratio interpretation, likelihood-ratio testing, and in-sample classification evaluation.

## Key Results

The supplied analysis produced:

| Metric | Result |
|---|---:|
| Observations | 1,013 |
| Predictors | 6 |
| Overall accuracy | 54.83% |
| Cohen's Kappa | 0.3055 |
| McFadden pseudo-R² | 0.2151 |
| Likelihood-ratio statistic | 473.4933 |
| LR test degrees of freedom | 5 |

Significant predictors in the fitted model:

| Predictor | p-value | Odds Ratio |
|---|---:|---:|
| Age | 0.0399 | 0.988 |
| SystolicBP | < 0.001 | 1.050 |
| DiastolicBP | 0.1624 | 0.990 |
| BS | < 0.001 | 2.780 |
| HeartRate | < 0.001 | 1.042 |

`BodyTemp` was not retained as a coefficient in the reported fitted model because `polr()` issued a rank-deficiency warning and dropped a coefficient.

Per-class evaluation from the supplied analysis:

| Class | Sensitivity | Specificity | Precision | F1 |
|---|---:|---:|---:|---:|
| Low risk | 0.653 | 0.640 | 0.548 | 0.596 |
| Mid risk | 0.310 | 0.720 | 0.354 | 0.330 |
| High risk | 0.688 | 0.934 | 0.792 | 0.736 |

## Important Interpretation Note

This repository documents an academic statistical analysis. The reported classification metrics are **in-sample metrics**, because predictions were evaluated on the same cleaned dataset used to fit the model. They should not be interpreted as an estimate of out-of-sample or clinical performance.

This project is not a clinical decision-support tool and should not be used to diagnose or triage patients.

## Repository Structure

```text
maternal-health-risk-ordinal-logistic-regression/
├── README.md
├── LICENSE
├── .gitignore
├── R/
│   └── analysis.R
├── data/
│   ├── maternal-health-risk.csv
│   └── README.md
└── docs/
    └── project-paper.pdf
```

## Dataset

The dataset is the **Maternal Health Risk** dataset from the UCI Machine Learning Repository (Dataset ID 863).

UCI reports 1,013 instances and 6 predictor features plus the target variable. The dataset is licensed under **CC BY 4.0**.

Source:
https://archive.ics.uci.edu/dataset/863/maternal+health+risk

Citation:
Ahmed, M. (2020). *Maternal Health Risk* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5DP5D

## Reproducibility

The analysis is written in R and uses:

- MASS
- ggplot2
- dplyr
- corrplot
- GGally
- tidyr
- caret
- car

Run `R/analysis.R` from the repository root after installing the required packages.

## Team

- Aaron Jeremy Alexander
- M. Aufa Mumtaza Ibadillah
- Ryu Orlando Tamin

School of Computer Science, BINUS University.

## Scope

This repository is a cleaned portfolio version of an academic project. Student NIMs, student email addresses, contribution-sheet metadata, and Turnitin/submission artifacts are intentionally excluded from the public repository.
