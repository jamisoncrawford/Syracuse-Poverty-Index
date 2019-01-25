# Syracuse Poverty Index

**Description:** An index of historical data of community indicators in Syracuse's 55 census tracts, normalized and scored for comparability and aggregated to indicate the overall economic and social health of each census tract.

**Variable Definitions:** See `CodeBook.md`.

**Software:** Manual wrangling of partner-provided data is performed in worksheets via *Microsoft Excel 2018* (Windows 10).
All cleaning, manipulation, analysis, and visualization is perfromed using R (v. 3.5.1) in the RStudio IDE (v. 1.1.456) using Windows 10.

**Objective:** Since data sources are from local service providers and data intermediaries, indicators in the Index serve as a far more accurate, robust measure for "moving" the proverbial "needle", a superior measure of community wellbeing at census tract granularity than ACS Census estimates.

## Disparate Sources & Preprocessing

The majority of data sources are comprised of partner organizations, e.g. Department of Social Services, Onondaga County Health Department, Syracuse City School District, etc., and while these are largely raw data, they are often structured inconsistenty, or include census tracts outside of Syracuse, NY. Therefore, these data are manually restructured into [Tidy Format](https://vita.had.co.nz/papers/tidy-data.pdf) in *MS Excel 2018*.

* A redacted version of processed, tidy data are available in [Tables](https://github.com/jamisoncrawford/Syracuse-Poverty-Index/tree/master/Tables): `Poverty Index Datasets 0.9.1 - Redacted`
* The R script for preprocessing Temporary Assistance data (Department of Social Services) is available in [Scripts](https://github.com/jamisoncrawford/Syracuse-Poverty-Index/tree/master/Scripts): `ta_cleaning_script_1.0`
* The R scripts for processing reported Type I crimes may be found in the repository [Syracuse Crime Analysis](https://github.com/jamisoncrawford/Syracuse-Crime-Analysis)

## Contributors

Frank Ridzi, PhD
Jamison Crawford, MPA
