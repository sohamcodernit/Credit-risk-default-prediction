Use CreditRiskDB;
-- 1. Overall portfolio default rate
USE CreditRiskDB;
GO

SELECT
    COUNT(*) AS Total_Borrowers,
    SUM(CAST(SeriousDlqin2yrs AS INT)) AS Total_Defaults,
    CAST(
        100.0 * SUM(CAST(SeriousDlqin2yrs AS INT))
        / COUNT(*)
        AS DECIMAL(6,2)
    ) AS Default_Rate_Pct
FROM dbo.credit_risk_cleaned;
------------------------------------
-- 2. Default rate by age group
SELECT
    CASE
        WHEN age <= 25 THEN '18-25'
        WHEN age <= 35 THEN '26-35'
        WHEN age <= 45 THEN '36-45'
        WHEN age <= 55 THEN '46-55'
        WHEN age <= 65 THEN '56-65'
        ELSE '66+'
    END AS Age_Group,

    COUNT(*) AS Borrowers,

    SUM(CAST(SeriousDlqin2yrs AS INT)) AS Defaults,

    CAST(
        100.0 * SUM(CAST(SeriousDlqin2yrs AS INT))
        / COUNT(*)
        AS DECIMAL(6,2)
    ) AS Default_Rate_Pct

FROM dbo.credit_risk_cleaned

GROUP BY
    CASE
        WHEN age <= 25 THEN '18-25'
        WHEN age <= 35 THEN '26-35'
        WHEN age <= 45 THEN '36-45'
        WHEN age <= 55 THEN '46-55'
        WHEN age <= 65 THEN '56-65'
        ELSE '66+'
    END

ORDER BY MIN(age);
------------------------------------
-- 3. Default rate by monthly income band
SELECT
    CASE
        WHEN MonthlyIncome IS NULL THEN 'Missing'
        WHEN MonthlyIncome <= 3000 THEN 'Low Income'
        WHEN MonthlyIncome <= 5000 THEN 'Lower-Middle'
        WHEN MonthlyIncome <= 7500 THEN 'Middle'
        WHEN MonthlyIncome <= 10000 THEN 'Upper-Middle'
        ELSE 'High Income'
    END AS Income_Band,
    COUNT(*) AS Borrowers,
    SUM(CAST(SeriousDlqin2yrs AS INT)) AS Defaults,
    CAST(
        100.0 * SUM(CAST(SeriousDlqin2yrs AS INT)) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS Default_Rate_Pct
FROM dbo.credit_risk_cleaned
GROUP BY
    CASE
        WHEN MonthlyIncome IS NULL THEN 'Missing'
        WHEN MonthlyIncome <= 3000 THEN 'Low Income'
        WHEN MonthlyIncome <= 5000 THEN 'Lower-Middle'
        WHEN MonthlyIncome <= 7500 THEN 'Middle'
        WHEN MonthlyIncome <= 10000 THEN 'Upper-Middle'
        ELSE 'High Income'
    END
ORDER BY MIN(MonthlyIncome);

------------------------------------
-- 4. Default rate by previous delinquency history
SELECT
    CASE
        WHEN Any_Delinquency = 1
            THEN 'Previous Delinquency'
        ELSE 'No Previous Delinquency'
    END AS Delinquency_Group,
    COUNT(*) AS Borrowers,
    SUM(CAST(SeriousDlqin2yrs AS INT)) AS Defaults,
    CAST(
        100.0 * SUM(CAST(SeriousDlqin2yrs AS INT)) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS Default_Rate_Pct
FROM dbo.credit_risk_cleaned
GROUP BY Any_Delinquency;
------------------------------------
-- 5. Default rate for borrowers with 90+ days past due
SELECT
    CASE
        WHEN Has_90Plus_Delinquency = 1
            THEN '90+ Days Late'
        ELSE 'No 90+ Days Late'
    END AS DPD_Group,
    COUNT(*) AS Borrowers,
    SUM(CAST(SeriousDlqin2yrs AS INT)) AS Defaults,
    CAST(
        100.0 * SUM(CAST(SeriousDlqin2yrs AS INT)) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS Default_Rate_Pct
FROM dbo.credit_risk_cleaned
GROUP BY Has_90Plus_Delinquency;
------------------------------------
-- 6. Analyze debt-ratio anomalies
SELECT
    CASE
        WHEN DebtRatio_Anomaly = 1 THEN 'Anomalous'
        ELSE 'Normal'
    END AS DebtRatio_Group,
    COUNT(*) AS Borrowers,
    SUM(CAST(SeriousDlqin2yrs AS INT)) AS Defaults,
    CAST(
        100.0 * SUM(CAST(SeriousDlqin2yrs AS INT)) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS Default_Rate_Pct
FROM dbo.credit_risk_cleaned
GROUP BY DebtRatio_Anomaly;
----------------------------------
-- 7. Default rate for high credit utilization
SELECT
    CASE
        WHEN High_Utilization_Flag = 1
            THEN 'Utilization > 100%'
        ELSE 'Utilization <= 100%'
    END AS Utilization_Group,
    COUNT(*) AS Borrowers,
    SUM(CAST(SeriousDlqin2yrs AS INT)) AS Defaults,
    CAST(
        100.0 * SUM(CAST(SeriousDlqin2yrs AS INT)) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS Default_Rate_Pct
FROM dbo.credit_risk_cleaned
GROUP BY High_Utilization_Flag;
-----------------------------------------
-- 8. Average utilization by target outcome
SELECT
    SeriousDlqin2yrs,
    COUNT(*) AS Borrowers,
    AVG(RevolvingUtilizationOfUnsecuredLines)
        AS Avg_Utilization
FROM dbo.credit_risk_cleaned
GROUP BY SeriousDlqin2yrs;
----------------------------------------------
-- 9. Combined risk segmentation
SELECT
    CASE
        WHEN Has_90Plus_Delinquency = 1
             AND High_Utilization_Flag = 1
            THEN 'Very High Risk'

        WHEN Any_Delinquency = 1
             AND High_Utilization_Flag = 1
            THEN 'High Risk'

        WHEN Any_Delinquency = 1
            THEN 'Moderate Risk'

        ELSE 'Lower Risk'
    END AS Risk_Segment,
    COUNT(*) AS Borrowers,
    SUM(CAST(SeriousDlqin2yrs AS INT)) AS Defaults,
    CAST(
        100.0 * SUM(CAST(SeriousDlqin2yrs AS INT)) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS Default_Rate_Pct
FROM dbo.credit_risk_cleaned
GROUP BY
    CASE
        WHEN Has_90Plus_Delinquency = 1
             AND High_Utilization_Flag = 1
            THEN 'Very High Risk'

        WHEN Any_Delinquency = 1
             AND High_Utilization_Flag = 1
            THEN 'High Risk'

        WHEN Any_Delinquency = 1
            THEN 'Moderate Risk'

        ELSE 'Lower Risk'
    END
ORDER BY
    CASE
        WHEN MAX(
            CASE
                WHEN Has_90Plus_Delinquency = 1
                     AND High_Utilization_Flag = 1
                    THEN 4
                WHEN Any_Delinquency = 1
                     AND High_Utilization_Flag = 1
                    THEN 3
                WHEN Any_Delinquency = 1
                    THEN 2
                ELSE 1
            END
        ) = 4 THEN 1
        ELSE 2
    END;
----------------------------------------
-- 10. Default rate by number of open credit lines
SELECT
    CASE
        WHEN NumberOfOpenCreditLinesAndLoans <= 2 THEN '0-2'
        WHEN NumberOfOpenCreditLinesAndLoans <= 5 THEN '3-5'
        WHEN NumberOfOpenCreditLinesAndLoans <= 10 THEN '6-10'
        ELSE '11+'
    END AS Credit_Line_Group,
    COUNT(*) AS Borrowers,
    SUM(CAST(SeriousDlqin2yrs AS INT)) AS Defaults,
    CAST(
        100.0 * SUM(CAST(SeriousDlqin2yrs AS INT)) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS Default_Rate_Pct
FROM dbo.credit_risk_cleaned
GROUP BY
    CASE
        WHEN NumberOfOpenCreditLinesAndLoans <= 2 THEN '0-2'
        WHEN NumberOfOpenCreditLinesAndLoans <= 5 THEN '3-5'
        WHEN NumberOfOpenCreditLinesAndLoans <= 10 THEN '6-10'
        ELSE '11+'
    END
ORDER BY MIN(NumberOfOpenCreditLinesAndLoans);
-------------------------------------------------