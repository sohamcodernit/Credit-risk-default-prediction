# Credit Risk Default Prediction & Portfolio Risk Analytics

A machine-learning and SQL analytics project exploring borrower delinquency, credit risk indicators, and portfolio-level risk patterns.

The goal of this project was to understand which borrower characteristics are associated with serious delinquency, build models to identify higher-risk borrowers, and translate the results into insights that could support credit-risk assessment.

Rather than relying on accuracy alone, I compared multiple models using ranking and classification metrics and used SQL to investigate patterns across borrower segments.

## Project Overview

Lenders face a fundamental challenge: identifying borrowers who may struggle to repay while avoiding unnecessary rejection of creditworthy applicants.

In this project, I worked with historical borrower data to:

- Clean inconsistent and extreme values while preserving useful data-quality information.
- Engineer features related to repayment history, credit utilization, and borrower characteristics.
- Train and compare Logistic Regression, Random Forest, and XGBoost classifiers.
- Evaluate model performance using ROC-AUC, KS, Gini, precision, recall, F1-score, and confusion matrices.
- Use SQL Server to analyze delinquency patterns and identify segments with elevated observed risk.

## Dataset

- **Dataset:** Give Me Some Credit
- **Original records:** 150,000
- **Records after cleaning:** 149,377
- **Target variable:** `SeriousDlqin2yrs`
- **Target meaning:** Whether a borrower experienced serious delinquency within the following two years.
- **Target-positive rate after cleaning:** Approximately 6.70%

The dataset contains borrower characteristics, including age, monthly income, debt ratio, revolving credit utilization, open credit lines, and historical delinquency counts.

The target represents the specific serious-delinquency event defined by the dataset; it should not be interpreted as every lender's formal definition of default.

## Methodology

### 1. Data Cleaning

I removed an unnecessary index column, filtered implausible ages, removed duplicate records, and investigated missing values and extreme observations.

I also identified special delinquency codes (`96` and `98`), created data-quality indicators for unusual debt ratios and utilization, and retained missing-value indicators where useful.

### 2. Feature Engineering

I created features to summarize borrower repayment behaviour and financial exposure, including:

- `Any_Delinquency`
- `Total_Delinquency_Count`
- `Has_90Plus_Delinquency`
- `High_Utilization_Flag`
- `Total_Open_Loans`
- Log-transformed income, debt ratio, and utilization
- Missing-value and anomaly indicators
- Age groups

### 3. Model Development

The cleaned data was split into training and testing sets using an 80:20 split with stratification on the target.

Numerical features were median-imputed and scaled, while categorical features were imputed and one-hot encoded. Preprocessing was fitted on the training data.

I trained three classification models:

- **Logistic Regression:** An interpretable baseline.
- **Random Forest:** An ensemble of decision trees capable of capturing nonlinear patterns.
- **XGBoost:** A gradient-boosted tree model designed for structured data.

Class weighting was used to address the imbalance between positive and negative cases.

## Model Performance

The models were evaluated on the held-out test set.

| Metric | Logistic Regression | Random Forest | XGBoost |
|---|---:|---:|---:|
| ROC-AUC | 0.8616 | 0.8664 | **0.8679** |
| KS Statistic | 0.5667 | 0.5798 | **0.5848** |
| Gini Coefficient | 0.7232 | 0.7328 | **0.7358** |
| Recall | 0.74 | 0.71 | **0.76** |
| Precision | 0.23 | **0.26** | 0.23 |
| F1-score | 0.35 | 0.38 | 0.35 |

### Interpreting the results

XGBoost achieved the highest ROC-AUC, KS, Gini, and recall among the three evaluated models. Its improvements over Random Forest were modest.

At the selected classification threshold, XGBoost identified approximately 76% of the positive cases, but its precision was 23%. This highlights the trade-off between detecting more potentially risky borrowers and generating false-positive flags.

The results suggest that the models can distinguish between higher- and lower-risk borrowers, but selecting an operational threshold would require further validation and consideration of business costs.


## Portfolio Risk Analysis Using SQL Server

I used SQL Server to examine how observed serious-delinquency rates varied across borrower characteristics and risk segments.

### Key Findings

**1. Previous delinquency is a strong risk indicator**

Borrowers with a history of delinquency had an observed serious-delinquency rate of **21.98%**, compared with **2.85%** among those without previous delinquency.

**2. Severe repayment delays are associated with elevated risk**

Borrowers with a history of 90+ days past due had an observed serious-delinquency rate of **41.25%**, compared with **4.73%** among those without that history.

**3. High revolving credit utilization identifies a higher-risk segment**

Borrowers with utilization above 100% had an observed rate of **37.25%**, compared with **6.01%** among the remaining borrowers.

**4. Risk indicators become more informative when combined**

A combined segmentation using delinquency history and high credit utilization showed the following observed rates:

| Risk segment | Borrowers | Serious-delinquency rate |
|---|---:|---:|
| Very High Risk | 1,013 | **59.82%** |
| High Risk | 1,144 | **40.91%** |
| Moderate Risk | 27,924 | **19.84%** |
| Lower Risk | 119,296 | **2.85%** |


These segments are exploratory, rule-based groups constructed from historical borrower characteristics. Their observed rates describe this dataset and should not be interpreted as calibrated predictions of an individual borrower's future probability of default.

## Technology Stack

- **Programming:** Python
- **Data Analysis:** Pandas, NumPy
- **Machine Learning:** Scikit-learn, XGBoost
- **Database & Analytics:** Microsoft SQL Server, SSMS
- **Visualization:** Matplotlib

## Key Takeaways

- Developed and compared three classification models on more than 149,000 borrower records.
- Achieved a ROC-AUC of 0.8679 and KS statistic of 0.5848 with XGBoost.
- Identified substantial differences in observed delinquency rates across repayment-history and credit-utilization groups.
- Used SQL-based segmentation to translate model-related analysis into portfolio-level risk insights.
- Explored the trade-off between identifying risky borrowers and generating false-positive flags.

## Limitations & Future Work

The observed relationships are not proof of causation. The project also has limitations that would need to be addressed before any real lending deployment.

Potential next steps include:

- Calibrating predicted probabilities and selecting thresholds based on business costs.
- Validating performance on later time periods and across borrower segments.
- Reviewing feature redundancy and the treatment of missing or anomalous data.
- Monitoring model stability and potential changes in borrower behaviour.
- Building an interactive Power BI dashboard for portfolio monitoring.
