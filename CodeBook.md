# Syracuse Poverty Index: Code Book

**Overview:** `CodeBook.md` provides data sources, upstream data pre-processing steps, variable and value transformations, units of analysis, and variable formulas and definitions for the *Syracuse Poverty Index*. 

## I. Data Nuances

### Raw Data

The [Central New York Community Foundation](https://cnycf.org/) (CNYCF) does not yet have full permission to host certain raw data comprising the *Syracuse Poverty Index*. The redacted table, `index_v7.1_redact.csv`, only contains data converted into scores.

### Missing Values

All missing values in `index_0.9.1_redact.csv` are indicated by `NA`, the standard for missing values in the R language. The analyst has taken several measures described herein to ensure that true missing values are distinct from "0" values:

* Missing `geoid` values are inserted during pre-processing, with `count` values set to "0".
* Merged data are checked against a data frame of true `NA` values to ensure true `NA` and true "0" values after transposition
* `NA` values in `crim` and `larc` variables are replaced with "0" prior to transforming to percentages in variables `crime_mprc` and `larceny_mprc`, respectively

### Monthly Totals & Time Intervals

One in every 55 rows in `index_0.9.1_redact.csv` contains a total of all population, parcel, and percentage variables, as well as the total `index` score for the `date`. All `date` values were converted to the "floor" (first day) of the month. Original variables with suffix `*prc` have prefixes representing the interval in which they are collected.

* `tprc` indicates an all-time aggregation
* `aprc` indicates an annual aggregation
* `qprc` indicates a quarterly aggregation
* `mprc` indicates a monthly aggregation

These have since been deprecated in final versions, which now have more human-reabable data.

To accomodate the monthly breakdown in `index_0.9.1_redact.csv`, `qprc` (quarterly) values are replicated across 3 months, `aprc` (annual) values are replicated across 12 months, and `tprc` (all-time) are replicated across all months in the *Index*.

## II. Variable Descriptions & Sources

Data from the *Syracuse Poverty Index* are pulled from the following sources by variable. Refer to `index_0.9.1_redact` to view each variable and its values.

1. `Total Pop.` is the **total population** within a census tract per US Census American Community Survey, or ACS (2015)
    - Deprecated name: `tpop`

2. `Adult Pop.` is the **total adult population, ages 18-64** within a census tract per US Census ACS (2015)
    - Deprecated name: `apop`

3. `Working Pop.` is the **total population in workforce** within a census tract per US Census ACS (2015)
    - Deprecated name: `wpop`

4. `Properties` is the **total property parcels** within a census tract per City of Syracuse's Neighborhood & Business Development (2016)
    - Deprecated name: `prop`

5. `Child Lead Perc.` is the **annual percentage of children with lead poisoning** within a census tract per Onondaga County Health Department, or OCHD (2017)
    - Deprecated name: `child_lead_aprc`

6. `Crime, No Larceny` is the **monthly per capita reported Type 1 crimes exlcuding larceny** within a census tract as reported by Syracuse Police Department and maintained in the *Syracuse Post Standard* [Crime Database](https://www.syracuse.com/crime/index.ssf/page/police_reports.html) (2016-Present)
    - Deprecated name: `crime_mprc`

7. `G3 ELA Failure Rate` is the **annual percentage of children failing third-grade ELA exam** within a census tract per Syracuse City School District, or SCSD (2016-2017)
    - Deprecated name: `ela_fail_aprc`

8. `ELA Failure Rate, Impoverished` is the **annual percentage of children failing third-grade ELA exam** within a census tract per Syracuse City School District, or SCSD (2016-2017)

9. `Crime, Larceny Only` is the **monthly per capita reported larceny** within a census tract as reported by Syracuse Police Department and maintained in the *Syracuse Post Standard* [Crime Database](https://www.syracuse.com/crime/index.ssf/page/police_reports.html) (2016-Present)
    - Deprecated name: `larceny_mprc`

10. `Mean Wages v. County` is the **quarterly percent difference in average disbursed tract wage to average earned county wage** per US Department of Labor (DOL) Quarterly Census of Wages and Employment (QCEW); notably, CNYCF purchases tract-level data from the DOL, though less granular albeit Open QCEW Data is available in the [DOL QCEW Database](https://www.bls.gov/cew/) (Q3, 2016-Q4, 2017)
    - Deprecated name: `wages_qprc`

11. `Temp. Assist Cases per Working Population` is the **monthly percentage of temporary assistance cases among workforce** within a census tract per Onondaga County Department of Social Services (DSS); these data are currently available upon request to CNYCF (June-July, 2017; November, 2017-June, 2018)
    - Deprecated name: `ta_case_mprc`

12. `Temp. Assist Individuals per Working Population` is the **monthly percentage of individuals on temporary assistance among workforce** within a census tract per Onondaga County Department of Social Services (DSS); these data are currently available upon request to CNYCF (July, 2017; November, 2017-Present)
    - Deprecated name: `ta_inds_mprc`

13. `Unemployed Population` is the **monthly percentage of unemployment insurance beneficiaries among workforce** within a census tract per DOL; notably, CNYCF purchases tract-level data from DOL and they are available upon request to CNYCF (2017-Present)
    - Deprecated name: `unemployment_mprc`

14. `Parcels with Vacancies` is the **quarterly percentage of properties with at least one verified vacancy over properties with structures** within a census tract, provided by Syracyse Neighborhood & Business Development (NBD)
    - Deprecated name: `vacancy_qprc`

## III. Variable Transformations

All variable transformations occur in line 186 of thr R script `poverty_index_v2.r` and are explained below. Note: All variables *that are not pre-processed* are converted from percentages by multiple each value by 100.

1. `Child Lead Poison Rate` or **annual percentage of children with lead poisoning** is pre-calculated by OCHD upstream as the proportion of total children (under 6 years of age) in each tract with reportedly toxic levels of lead (EBLL).

2. `Other Crime per Capita` or **monthly per capita reported Type 1 crimes exlcuding larceny** is calculated by dividing monthly reports of Type I tract crime excluding larceny, `crim`, by the total tract population, `tpop`, over 100 for per capita values.
 
<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?%5Cfrac%7Bmonthly%5C%3B%20tract%5C%3B%20crime%7D%7B%28%5C%3A%20tract%20%5C%3A%20population%5C%3A%20/%20%5C%3A%20100%5C%3A%20%29%7D" />
</p>

3. `G3 ELA Failure Rate` or **annual percentage of children failing third-grade ELA exam** is pre-calculated by SCSD upstream as the proportion of total third-grade students within each tract who performed below grade level in the Grade 3 ELA (English Language Arts) exam.
        - For comparative purposes, this score is reduced to 10% of its value, representing 1 in 10 students
        - This is preprocessed similarly for variable `ELA Failure Rate, Impoverished`

4. `Larceny per Capita` is the **monthly per capita reported larceny** is calculated by dividing monthly reports of tract larceny, `larc`, by the total tract population, `tpop`, over 100 for per capita values.

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?%5Cfrac%7Bmonthly%5C%3B%20tract%5C%3B%20larceny%7D%7B%28%5C%3A%20tract%20%5C%3A%20population%5C%3A%20/%20%5C%3A%20100%5C%3A%20%29%7D" />
</p>

5. `Mean Wages v. County` or **quarterly percent difference in average disbursed tract wage to average earned county wage** is calculated by subtracting the quarterly average wages disbursed in tract, `qcew`, from the average quarterly pre-tax earnings in Onondaga County, $12,012. The difference is again divided by average quarterly pre-tax earnings, $12,012, to determine percent difference. All negative differences (i.e. tracts with above-average disbursed wages) are replaced with scores of "0".

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?%5Cmathbb%7BR_%5Cgeq%20%7D_0%3D%5Cfrac%7B%28%5C%3A%20quarterly%20%5C%3A%20average%5C%3A%20county%5C%3A%20wages%5C%3A%20earned%5C%3A%20-%20%5C%3A%20quarterly%20%5C%3A%20average%20%5C%3A%20tract%5C%3A%20wages%5C%3A%20disbursed%5C%3A%20%29%7D%7Bquarterly%20%5C%3A%20average%5C%3A%20county%5C%3A%20wages%7D" />
</p>

6. `Temp. Assist Cases per Working Population` or **monthly percentage of temporary assistance cases among workforce** is calculated by dividing the monthly total of temporary assistance cases by tract, `tac`, by total workforce population in tract, `wpop`.

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?%5Cfrac%7Bmonthly%5C%3A%20tract%5C%3A%20temporary%5C%3A%20assistance%5C%3A%20cases%7D%7B%5C%3A%20total%5C%3A%20tract%20%5C%3A%20workforce%5C%3A%20%7D" />
</p>

7. `Temp. Assist Individuals per Working Population` or **monthly percentage of individuals on temporary assistance among workforce** is calculated by dividing the monthly total of temporary assistance beneficiaries by tract, `tai`, by total workforce population in tract, `wpop`.

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?%5Cfrac%7Bmonthly%5C%3A%20tract%5C%3A%20temporary%5C%3A%20assistance%5C%3A%20individuals%7D%7B%5C%3A%20total%5C%3A%20tract%20%5C%3A%20workforce%5C%3A%20%7D" />
</p>

8. `Unemployed Population` or **monthly percentage of unemployment insurance beneficiaries among workforce** is calculated by dividing the monthly total of unemployment insurance beneficiaries in tract, `uib`, by total workforce population in tract, `wpop`.

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?%5Cfrac%7Bmonthly%5C%3A%20tract%5C%3A%20unemployment%5C%3A%20insurance%5C%3A%20beneficiaries%7D%7B%5C%3A%20total%5C%3A%20tract%20%5C%3A%20workforce%5C%3A%20%7D" />
</p>

9. `Parcels with Vacancies` or **quarterly percentage of property parcels with reported vacancies** is calculated by dividing aggregated and verified vacant structures in tract, `vac`, by total tract properties with structues, `prop`.

<p align="center">
  <img src="https://latex.codecogs.com/gif.latex?%5Cfrac%7Bannual%5C%3A%20tract%5C%3A%20vacancies%5C%3A%20reported%7D%7B%5C%3A%20total%5C%3A%20tract%20%5C%3A%20parcels%5C%3A%20%7D" />
</p>
