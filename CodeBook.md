# Syracuse Poverty Index: Code Book

**Overview:** `CodeBook.md` provides data sources, upstream data pre-processing steps, variable and value transformations, and variable formulas and definitions for the *Syracuse Poverty Index*. 

### Note on Raw Data

The (Central New York Community Foundation)[cnycf.org] (CNYCF) does not yet have full permission to host certain raw data comprising the *Syracuse Poverty Index*. The redacted table, `index_v2_redact.csv`, only contains data converted into percentages.

### Missing Values

All missing values in `index_v2_redact.csv` are indicated by `NA`, the standard for missing values in the R language. The analyst has taken several measures described herein to ensure that true missing values are distinct from "0" values.

### Monthly Totals & Time Intervals

One in every 55 rows in `index_v2_redact.csv` contains a total of all population, parcel, and percentage variables, as well as the total `index` score for the `date`. All `date` values are the "floor" (first day) of the month. All variables with suffix `*prc` have prefixes representing the interval in which they are collected.

* `aprc` indicates an annual aggregate percentage
* `qprc` indicates a quarterly aggregate percentage
* `mprc` indicates a monthly aggregate percentage

To accomodate the monthly breakdown in `index_v2_redact.csv`, `qprc` (quarterly) values are replicated across 3 months and `aprc` (annual) values are replicated across 12 months. 

## Variable Descriptions & Sources

Data from the *Syracuse Poverty Index* are pulled from the following sources by variable. Refer to `index_v2_redact` to view each variable and its values.

1. `tpop` is the **total population** within a census tract per US Census American Community Survey, or ACS (2015)
2. `apop` is the **total adult population, ages 18-64** within a census tract per US Census ACS (2015)
3. `wpop` is the **total population in workforce** within a census tract per US Census ACS (2015)
4. `prop` is the **total property parcels** within a census tract per City of Syracuse's Neighborhood & Business Development (2016)
5. `child_lead_aprc` is the **annual percentage of children with lead poisoning** within a census tract per Onondaga County Heald Department, or OCHD (2017)
6. `ela_fail_aprc` is the **annual percentage of children failing third-grade ELA exam** within a census tract per Syracuse City School District, or SCSD (2016-2017)
7. `larceny_mprc` is the **monthly per capita reported larceny** within a census tract as reported by Syracuse Police Department and maintained in the *Syracuse Post Standard* [Crime Database](https://www.syracuse.com/crime/index.ssf/page/police_reports.html) (2016-Present)
8. `lead_aprc` is the **annual percentage of property parcels with reported lead violations** within a census tract as reported by OCHD and maintained in *Syracuse Open Data*, or [DataCuse](http://data.syrgov.net/datasets/lead-violations) (2017)
9. `unfit_aprc` is the **total percentage of property parcels declared "unfit"** within a census tract as reported by the Syracuse Department of Code Enforcement and maintained in [DataCuse](http://data.syrgov.net/datasets/unfit-properties) (2014-Present)
10. `wages_qprc` is the **quarterly percent difference in average disbursed tract wage to average earned county wage** per US Department of Labor (DOL) Quarterly Census of Wages and Employment (QCEW); notably, CNYCF purchases tract-level data from the DOL, though less granular albeit Open QCEW Data is available in the [DOL QCEW Database](https://www.bls.gov/cew/) (Q3, 2016-Q4, 2017)
11. `ta_case_mprc` is the **monthly percentage of temporary assistance cases among workforce** within a census tract per Onondaga County Department of Social Services (DSS); these data are currently available upon request to CNYCF (June-July, 2017; November, 2017-June, 2018)
12. `ta_inds_mprc` is the **monthly percentage of individuals on temporary assistance among workforce** within a census tract per Onondaga County Department of Social Services (DSS); these data are currently available upon request to CNYCF (July, 2017; November, 2017-Present)
13. `unemployment_mprc` is the **monthly percentage of unemployment insurance beneficiaries among workforce** within a census tract per DOL; notably, CNYCF purchases tract-level data from DOL and they are avaialble upon request to CNYCF (2017-Present)
14. `vacancy_aprc` is the **annual percentage of property parcels with reported vacancies** within a census tract per a combination of annual aggregates provided by NBD (2014, 2016) and NBD data maintained by [DataCuse](http://data.syrgov.net/datasets/parcel-data-august-2017) (2017)
15. `violation_aprc` is the **annual percentage of property parcels with reported housing violations** within a census tract per a combination of annual aggregates of NBD data (2014, 2016) and Department of Code Enforcement maintained by [DataCuse](http://data.syrgov.net/datasets/code-violations) (2017)
