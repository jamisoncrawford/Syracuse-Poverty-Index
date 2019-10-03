SYRACUSE POVERTY INDEX

Version: 0.14.2
Last Update: 2019-10-02
Author: Jamison R. Crawford

I. INDEX FORMATS

(1) index_0.9.0.csv

	3,417 rows
	   28 columns

	- All variables, with human-readable names
	- Now includes "Tract", abbreviation of "geoid"
	- No redacted data
	- NAs removed

(2) index_0.9.0_redact.csv

	3,417 rows
	   18 columns

	- Same as "index_0.9.0.csv"
	- Removes all raw count data from collaborators
	- Preserves ACS estimates

(3) index_0.9.0_tidy.csv

	85,401 rows
	     5 columns

	- All variables, no redactions
	- All variables now tidied under "Indicator" (Former Variables) and "Value" (Value)
	- "Month", "GEOID", and "Tract" are not tidied
	- NAs removed

(4) index_0.9.0_tidy_percents.csv

	37,577 rows
             4 columns

	- Only "Month", "GEOID", "Tract", "Indicator", & "Percent" variables
	- Human-readable variable names and "Indicator" values
	- Removes all raw count data from collaborators
	- All percentages, scores, and "Index Score" are tidied under "Indicator" & "Percent"
	- NAs removed

(5) index_0.9.0_tidy_raw.csv

	47,825 rows
	     5 columns

	- Same as "index_0.9.0_tidy_percents.csv"
	- Instead of percentages and scores, only contains ACS and collaborator data


II. UPDATE LOG

2019-01-16: Changed variable names to be more accurate (removed "per capita")
2019-02-07: Added January, 2019 TA data ("Temporary Assistance") 
2019-03-05: Added February, 2019 TA data ("Temporary Assistance")
2019-04-04: Added March, 2019 TA data ("Temporary Assistance")
2019-05-01: Updated OCHD EBLL Lead Format ("Child Lead")
2019-05-01: Added April, 2019 TA data ("Temporary Assistance"); Added Tract Abbreviations to SPI Datasets v. 0.11.0
2019-06-13: Updated DSS TA Data
2019-06-20: Updated OCHD EBLL Lead Format ("Child Lead"), Changed "Child Lead" Formula to Multiply by 100
2019-07-03: Updated DSS TA Data
2019-07-16: Updated NYS DOL UI Beneficiaries & QCEW (or "AQW"), and revised 2018 Q1 QCEW values
2019-07-16: Updated with Missing UI Beneficiaries Values
2019-08-07: Updated DSS TA Data
2019-08-21: Updated 2018 OCHD EBLL Data; Assigned version number to object name for script optimization
2019-09-09: Updated DSS TA Data
2019-10-02: Updated DSS TA Data