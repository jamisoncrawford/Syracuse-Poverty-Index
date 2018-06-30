# Syracuse Poverty Index: Code Book

**Overview:** `CodeBook.md` provides data sources, upstream data pre-processing steps, variable and value transformations, and variable formulas and definitions for the *Syracuse Poverty Index*. 

### Note on Raw Data

The [Central New York Community Foundation](cnycf.org) (CNYCF) does not yet have full permission to host certain raw data comprising the *Syracuse Poverty Index*. The redacted table, `index_v2_redact.csv`, only contains data converted into percentages.

### Missing Values

All missing values in `index_v2_redact.csv` are indicated by `NA`, the standard for missing values in the R language. The analyst has taken several measures described herein to ensure that true missing values are distinct from "0" values:

* Missing `geoid` values are inserted during pre-processing, with `count` values set to "0".
* Merged data are checked against a data frame of true `NA` values to ensure true `NA` and true "0" values after transposition
* `NA` values in `crim` and `larc` variables are replaced with "0" prior to transforming to percentages in variables `crime_mprc` and `larceny_mprc`, respectively

### Monthly Totals & Time Intervals

One in every 55 rows in `index_v2_redact.csv` contains a total of all population, parcel, and percentage variables, as well as the total `index` score for the `date`. All `date` values were converted to the "floor" (first day) of the month. All variables with suffix `*prc` have prefixes representing the interval in which they are collected.

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

5. `child_lead_aprc` is the **annual percentage of children with lead poisoning** within a census tract per Onondaga County Health Department, or OCHD (2017)

6. `crime_mprc` is the **monthly per capita reported Type 1 crimes exlcuding larceny** within a census tract as reported by Syracuse Police Department and maintained in the *Syracuse Post Standard* [Crime Database](https://www.syracuse.com/crime/index.ssf/page/police_reports.html) (2016-Present)

7. `ela_fail_aprc` is the **annual percentage of children failing third-grade ELA exam** within a census tract per Syracuse City School District, or SCSD (2016-2017)

8. `larceny_mprc` is the **monthly per capita reported larceny** within a census tract as reported by Syracuse Police Department and maintained in the *Syracuse Post Standard* [Crime Database](https://www.syracuse.com/crime/index.ssf/page/police_reports.html) (2016-Present)

9. `lead_aprc` is the **annual percentage of property parcels with reported lead violations** within a census tract as reported by OCHD and maintained in *Syracuse Open Data*, or [DataCuse](http://data.syrgov.net/datasets/lead-violations) (2017)

10. `unfit_aprc` is the **total percentage of property parcels declared "unfit"** within a census tract as reported by the Syracuse Department of Code Enforcement and maintained in [DataCuse](http://data.syrgov.net/datasets/unfit-properties) (2014-Present)

11. `wages_qprc` is the **quarterly percent difference in average disbursed tract wage to average earned county wage** per US Department of Labor (DOL) Quarterly Census of Wages and Employment (QCEW); notably, CNYCF purchases tract-level data from the DOL, though less granular albeit Open QCEW Data is available in the [DOL QCEW Database](https://www.bls.gov/cew/) (Q3, 2016-Q4, 2017)

12. `ta_case_mprc` is the **monthly percentage of temporary assistance cases among workforce** within a census tract per Onondaga County Department of Social Services (DSS); these data are currently available upon request to CNYCF (June-July, 2017; November, 2017-June, 2018)

13. `ta_inds_mprc` is the **monthly percentage of individuals on temporary assistance among workforce** within a census tract per Onondaga County Department of Social Services (DSS); these data are currently available upon request to CNYCF (July, 2017; November, 2017-Present)

14. `unemployment_mprc` is the **monthly percentage of unemployment insurance beneficiaries among workforce** within a census tract per DOL; notably, CNYCF purchases tract-level data from DOL and they are available upon request to CNYCF (2017-Present)

15. `vacancy_aprc` is the **annual percentage of property parcels with reported vacancies** within a census tract per a combination of annual aggregates provided by NBD (2014, 2016) and NBD data maintained by [DataCuse](http://data.syrgov.net/datasets/parcel-data-august-2017) (2017)

16. `violation_aprc` is the **annual percentage of property parcels with reported housing violations** within a census tract per a combination of annual aggregates of NBD data (2014, 2016) and Department of Code Enforcement maintained by [DataCuse](http://data.syrgov.net/datasets/code-violations) (2017)

## Variable Transformations (Percentages)

All variable transformations occur in line 186 of thr R script `poverty_index_v2.r` and are explained below. Note: All variables *that are not pre-processed* are converted from percentages by multiple each value by 100.

1. `child_lead_aprc` or **annual percentage of children with lead poisoning** is pre-calculated by OCHD upstream as the proportion of total children (under 18 years of age) in each tract with reportedly toxic levels of lead.

2. `crime_mprc` or **monthly per capita reported Type 1 crimes exlcuding larceny** is calculated by dividing monthly reports of Type 1 tract crime excluding larceny, `crim`, by the total tract population, `tpop`, over 1,000 for per capita values.

<a href="https://www.codecogs.com/eqnedit.php?latex=\frac{monthly\;&space;tract\;&space;crimes}{(\:&space;population\:&space;/&space;\:&space;1,000\:&space;)}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\frac{monthly\;&space;tract\;&space;crimes}{(\:&space;population\:&space;/&space;\:&space;1,000\:&space;)}" title="\frac{monthly\; tract\; crimes}{(\: population\: / \: 1,000\: )}" /></a>

3. `ela_fail_aprc` or **annual percentage of children failing third-grade ELA exam** is pre-calculated by SCSD upstream as the proportion of total thrid-grade students within each tract who failed the Grade 3 ELA (English Language Arts) exam.

4. `larceny_mprc` is the **monthly per capita reported larceny** is calculated by dividing monthly reports of tract larceny, `larc`, by the total tract population, `tpop`, over 1,000 for per capita values.

<a href="https://www.codecogs.com/eqnedit.php?latex=\frac{monthly\;&space;tract\;&space;larceny}{(\:&space;population\:&space;/&space;\:&space;1,000\:&space;)}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\frac{monthly\;&space;tract\;&space;larceny}{(\:&space;population\:&space;/&space;\:&space;1,000\:&space;)}" title="\frac{monthly\; tract\; larceny}{(\: population\: / \: 1,000\: )}" /></a>

5. `lead_aprc` or **annual percentage of property parcels with reported lead violations** is calculated by dividing aggregated annual reports of tract lead violations, `lead` by total tract property parcels, `prop`.

<a href="https://www.codecogs.com/eqnedit.php?latex=\frac{tract\:&space;lead\:&space;violations}{(\:&space;total\:&space;parcels\:&space;)}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\frac{tract\:&space;lead\:&space;violations}{(\:&space;total\:&space;parcels\:&space;)}" title="\frac{tract\: lead\: violations}{(\: total\: parcels\: )}" /></a>

6. `unfit_aprc` or **total percentage of property parcels declared "unfit"** is calculated by dividing all-time aggregated declarations of unfit housing in tract, `nfit`, by total tract property parcels, `prop`.



7. `wages_qprc` or **quarterly percent difference in average disbursed tract wage to average earned county wage** is calculated by subtracting the quarterly average wages disbursed in tract, `qcew`, from the average quarterly pre-tax earnings in Onondaga County, $12,012. The difference is again divided by average quarterly pre-tax earnings, $12,012, to determine percent difference. All negative differences (i.e. tracts with above-average disbursed wages) are replaced with "0".

8. `ta_case_mprc` or **monthly percentage of temporary assistance cases among workforce** is calculated by dividing the monthly total of temporary assistance cases by tract, `tac`, by total workforce population in tract, `wpop`.

9. `ta_inds_mprc` or **monthly percentage of individuals on temporary assistance among workforce** is calculated by dividing the monthly total of temporary assistance beneficiaries by tract, `tai`, by total workforce population in tract, `wpop`.

10. `unemployment_mprc` or **monthly percentage of unemployment insurance beneficiaries among workforce** is calculated by dividing the monthly total of unemployment insurance beneficiaries in tract, `uib`, by total workforce population in tract, `wpop`.

11. `vacancy_aprc` or **annual percentage of property parcels with reported vacancies** is calculated by dividing aggregated annual reported vacant properties in tract, `vac`, by total tract property parcels, `prop`.

12. `violation_aprc` or **annual percentage of property parcels with reported housing violations** is calculated by dividing aggregated annual reported housing violations in tract, `viol`, by total tract property parcels, `prop`.
