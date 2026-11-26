/*
AQ-009: Which of the 23 financial KPIs are comparable across
SBI and the five peer banks after reviewing source definitions,
periods, units, and reporting bases?

ANSWER:

The peer benchmarking analysis will cover 18 selected financial
KPIs from the consolidated financial dataset for SBI, Axis Bank,
Bank of Baroda, HDFC Bank, ICICI Bank, and Punjab National Bank.

The selected KPIs are:

1. Total Assets
2. Total Deposits
3. Gross Advances
4. Net Interest Income (NII)
5. Operating Profit
6. Net Profit (PAT)
7. Net Interest Margin (NIM)
8. Return on Assets (ROA)
9. Gross NPA (GNPA) Ratio
10. Net NPA (NNPA) Ratio
11. CASA Ratio
12. Capital Adequacy Ratio (CRAR)
13. Common Equity Tier 1 (CET1) Ratio
14. Provision Coverage Ratio (PCR)
15. Cost-to-Income Ratio
16. Earnings Per Share (EPS)
17. Book Value Per Share
18. Net Profit Growth

The remaining five growth metrics are excluded from the
current benchmarking scope as they are not required by
the selected analytical questions.

All comparisons will use the existing financial KPI values
for FY2021-22 to FY2025-26.

*/

/*
AQ-010: For the KPIs confirmed comparable, how did annual
bank-level financial values compare across SBI and the
five peer banks?
*/

/*
AQ-010: For the KPIs confirmed comparable, how did annual bank-level
financial values compare across SBI and the five peer banks?
*/

SELECT
    bank,
    financial_year,
    total_assets,
    total_deposits,
    gross_advances,
    nii,
    operating_profit,
    net_profit_pat,
    nim,
    roa,
    gnpa_ratio,
    nnpa_ratio,
    net_profit_growth,
    casa_ratio,
    crar,
    cet1_ratio,
    pcr,
    cost_to_income_ratio,
    eps,
    book_value_per_share

FROM bank_financial_kpis

ORDER BY
    financial_year,
    bank;


/*
AQ-011: Which banks reported the highest and lowest PAT in each financial year?
*/
/*
AQ-011: Which banks reported the highest and lowest PAT in each financial year?
*/

WITH ranked_banks AS (
    SELECT
        bank,
        financial_year,
        net_profit_pat,
        RANK() OVER (
            PARTITION BY financial_year
            ORDER BY net_profit_pat DESC NULLS LAST
        ) AS highest_rank,
        RANK() OVER (
            PARTITION BY financial_year
            ORDER BY net_profit_pat ASC NULLS LAST
        ) AS lowest_rank
    FROM bank_financial_kpis
    WHERE net_profit_pat IS NOT NULL
)

SELECT
    financial_year,
    bank,
    net_profit_pat,
    CASE
        WHEN highest_rank = 1 THEN 'Highest PAT'
        WHEN lowest_rank = 1 THEN 'Lowest PAT'
    END AS pat_position
FROM ranked_banks
WHERE highest_rank = 1
   OR lowest_rank = 1
ORDER BY
    financial_year,
    highest_rank;

/*
AQ-012: How did source-reported Net Profit Growth compare across banks and financial years?
*/

SELECT
    bank,
    financial_year,
    net_profit_growth
FROM bank_financial_kpis
WHERE net_profit_growth IS NOT NULL
ORDER BY
    financial_year,
    net_profit_growth DESC;


/*
AQ-013: For each financial year, how did each bank’s GNPA Ratio compare
with the descriptive average of comparable peer-bank ratios?
*/

SELECT
    b.bank,
    b.financial_year,
    b.gnpa_ratio,
    ROUND(AVG(p.gnpa_ratio), 2) AS peer_average_gnpa,
    ROUND(b.gnpa_ratio - AVG(p.gnpa_ratio), 2) AS difference_from_peer_average
FROM bank_financial_kpis b
JOIN bank_financial_kpis p
    ON b.financial_year = p.financial_year
    AND b.bank <> p.bank
WHERE b.gnpa_ratio IS NOT NULL
GROUP BY
    b.bank,
    b.financial_year,
    b.gnpa_ratio
ORDER BY
    b.financial_year,
    b.bank;

/*
AQ-014: How did reported NIM and ROA compare across banks by financial year?
*/

SELECT
    bank,
    financial_year,
    nim,
    roa
FROM bank_financial_kpis
WHERE nim IS NOT NULL
   OR roa IS NOT NULL
ORDER BY
    financial_year,
    bank;

/*
AQ-015: How did reported CRAR, CET1 Ratio, and CASA Ratio compare across banks by financial year?
*/

SELECT
    bank,
    financial_year,
    crar,
    cet1_ratio,
    casa_ratio
FROM bank_financial_kpis
WHERE crar IS NOT NULL
   OR cet1_ratio IS NOT NULL
   OR casa_ratio IS NOT NULL
ORDER BY
    financial_year,
    bank;

/*
AQ-016: How did each bank’s Cost-to-Income Ratio compare with the descriptive peer-bank average by financial year?
*/

SELECT
    b.bank,
    b.financial_year,
    b.cost_to_income_ratio,
    ROUND(AVG(p.cost_to_income_ratio), 2) AS peer_average_cost_to_income,
    ROUND(
        b.cost_to_income_ratio - AVG(p.cost_to_income_ratio),
        2
    ) AS difference_from_peer_average
FROM bank_financial_kpis b
JOIN bank_financial_kpis p
    ON b.financial_year = p.financial_year
    AND b.bank <> p.bank
WHERE b.cost_to_income_ratio IS NOT NULL
  AND p.cost_to_income_ratio IS NOT NULL
GROUP BY
    b.bank,
    b.financial_year,
    b.cost_to_income_ratio
ORDER BY
    b.financial_year,
    b.bank;

/*
AQ-017: How did SBI’s annual rank change for each individual financial KPI confirmed as comparable?
*/

WITH sbi_ranks AS (
    SELECT
        bank,
        financial_year,
        RANK() OVER (PARTITION BY financial_year ORDER BY total_assets DESC) AS total_assets_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY total_deposits DESC) AS total_deposits_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY gross_advances DESC) AS gross_advances_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY nii DESC) AS nii_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY operating_profit DESC) AS operating_profit_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY net_profit_pat DESC) AS net_profit_pat_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY nim DESC) AS nim_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY roa DESC) AS roa_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY gnpa_ratio ASC) AS gnpa_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY nnpa_ratio ASC) AS nnpa_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY net_profit_growth DESC) AS net_profit_growth_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY casa_ratio DESC) AS casa_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY crar DESC) AS crar_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY cet1_ratio DESC) AS cet1_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY pcr DESC) AS pcr_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY cost_to_income_ratio ASC) AS cost_to_income_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY eps DESC) AS eps_rank,
        RANK() OVER (PARTITION BY financial_year ORDER BY book_value_per_share DESC) AS book_value_per_share_rank
    FROM bank_financial_kpis
)

SELECT *
FROM sbi_ranks
WHERE bank = 'SBI'
ORDER BY financial_year;

