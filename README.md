# Syracuse Poverty Index

**Description:** An index of historical data of community indicators in Syracuse's 55 census tracts, normalized and scored for comparability and aggregated to indicate the overall economic and social health of each census tract.

**Variable Definitions:** See `CodeBook.md`.

**Software:** Manual wrangling of partner-provided data is performed in worksheets via *Microsoft Excel 2018* (Windows 10).
All cleaning, manipulation, analysis, and visualization is perfromed using R (v. 3.5.1) in the RStudio IDE (v. 1.1.456) using Windows 10.

**Objective:** Since data sources are from local service providers and data intermediaries, indicators in the Index serve as a far more accurate, robust measure for "moving" the proverbial "needle", a superior measure of community wellbeing at census tract granularity than ACS Census estimates.

## Disparate Sources & Preprocessing

The majority of data sources are comprised of partner organizations, e.g. Department of Social Services, Onondaga County Health Department, Syracuse City School District, etc., and while these are largely raw data, they are often structured inconsistenty, or include census tracts outside of Syracuse, NY. Therefore, these data are manually restructured into [Tidy Format](https://vita.had.co.nz/papers/tidy-data.pdf) in *MS Excel 2018*.

* A redacted version of processed, tidy data are available in [Tables](https://github.com/jamisoncrawford/Syracuse-Poverty-Index/tree/master/Tables): `Poverty Index Datasets 0.9.1 - Redacted`
* The R script for preprocessing DSS (Department of Social Services) data is available in [Scripts](https://github.com/jamisoncrawford/Syracuse-Poverty-Index/tree/master/Scripts): `ta_conversion.r`
* The R scripts for processing reported Type I crimes may be found in the repository [Syracuse Crime Analysis](https://github.com/jamisoncrawford/Syracuse-Crime-Analysis)
    - This repository also documents all tasks for reproducibility
* The final scoring script, `poverty_index_0.9.1.r`, merges and restructures all data sources (see [Scripts](https://github.com/jamisoncrawford/Syracuse-Poverty-Index/tree/master/Scripts))
* A redacted final index is provided in [Tables](https://github.com/jamisoncrawford/Syracuse-Poverty-Index/tree/master/Tables) in both long and wide format:
    - Wide (Semi-Tidy): `index_0.9.1_redact.csv`
    - Long (Tidy): `index_0.9.1_tidy.csv`
    
## Next Steps

Alternative scoring systems are being explored, while v. 1.0 will debut in a whitepaper c. February, 2019.

## Contributors

* Frank Ridzi, PhD
* Jamison Crawford, MPA
