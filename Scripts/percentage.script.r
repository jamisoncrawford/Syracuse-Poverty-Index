###--------------------------------------------------------------### 
### INDICATORS AS PERCENTAGES BY CENSUS TRACT

# R version 3.4.3
# RStudio version 1.1.414

RStudio.Version()

# DESCRIPTION: Preps "Housing" data on "Unfit Properties"
# SOURCE: City of Syracuse, Department of Labor, Census ACS, etc.

#--------------------------------------------------------------#
# CLEAR LIBRARY; INSTALL & LOAD PACKAGES; READ IN DATA, SELECT VARIABLES, & COERCE CLASSES

rm( list = ls() )

if( !require( dplyr ) ) { install.packages( "dplyr" ) }
if( !require( tidyr ) ) { install.packages( "tidyr" ) }
if( !require( tidyr ) ) { install.packages( "purrr" ) }
if( !require( readxl ) ) { install.packages( "readxl" ) }
if( !require( censusr ) ) { install.packages( "censusr" ) }
if( !require( stringr ) ) { install.packages( "stringr" ) }
if( !require( lubridate ) ) { install.packages( "lubridate" ) }

library( dplyr )
library( tidyr )
library( purrr )
library( readxl )
library( censusr )
library( stringr )
library( lubridate )

setwd( "~/CNYCF/Poverty Index/Percentage Protoype" )

original <- read.csv( "~/CNYCF/Poverty Index/Simple Combine Script/Simple Tidy Index Data.csv" ) %>%
  select( GEOID,
          Indicator,
          Date,
          Value )

original$GEOID <- as.character( original$GEOID )

#--------------------------------------------------------------#
# POPULATION DENOMINATORS BY TRACT

populations <- original %>%
  filter( Indicator == "TPOP" | Indicator == "APOP" ) %>%
  select( GEOID,
          Indicator,
          Value ) %>%
  spread( key = Indicator, value = Value )

colnames( populations ) <- c( "GEOID",
                              "adult_pop",
                              "total_pop" )

rm( original )

#--------------------------------------------------------------#
# MEAN QUARTERLY WAGES BY CENSUS TRACT (2017), I.E. "qcew"

qcew <- read.csv( "qcew_table.csv" )
qcew$Month <- mdy( qcew$Month ) 
qcew$GEOID <- as.character( qcew$GEOID )

qcew <- qcew[ rep( seq_len( nrow( qcew )), each = 3 ), ]

for( i in 1:165 ) {
  if ( str_detect( string = rownames( qcew )[i], pattern = "\\.1" )){
    qcew$Month[i] <- date( "2017-08-01" )
  } else if ( str_detect( string = rownames( qcew )[i], pattern = "\\.2" )){
    qcew$Month[i] <- date( "2017-09-01" )
  } else {
    qcew$Month[i] <- date( "2017-07-01" )
  }
}

for( i in 166:nrow( qcew ) ) {
  if ( str_detect( string = rownames( qcew )[i], pattern = "\\.1" )){
    qcew$Month[i] <- date( "2017-11-01" )
  } else if ( str_detect( string = rownames( qcew )[i], pattern = "\\.2" )){
    qcew$Month[i] <- date( "2017-12-01" )
  } else {
    qcew$Month[i] <- date( "2017-10-01" )
  }
}

qcew <- qcew %>% 
  arrange( Month )

colnames( qcew ) <- c( "GEOID",
                       "month",
                       "qcew" )

rm( i )

## Replace All NA Values with "0"

qcew[ is.na( qcew ) ] <- 0

#--------------------------------------------------------------#
# UNEMPLOYMENT BY CENSUS TRACT

unemployment <- read.csv( "unemployment_table.csv" )

unemployment$GEOID <- as.character( unemployment$GEOID )
unemployment$Date <- mdy( unemployment$Date )
unemployment$Unemployed <- as.integer( unemployment$Unemployed )

colnames( unemployment ) <- c( "GEOID",
                               "month",
                               "unemployed" )

## Replace All NA Values with "0"

unemployment[ is.na( unemployment ) ] <- 0

#--------------------------------------------------------------#
# TEMPORARY ASSISTANCE

ta <- read.csv( "ta_cases_table.csv" )

colnames( ta ) <- c( "tract",
                     "month",
                     "temp_assist" )

ta$month <- str_replace_all( string = as.character( mdy( ta$month )), 
                             pattern = ".{2}$", 
                             replacement = "01")

ta$tract <- str_pad( ta$tract, 
                     width = 6, 
                     pad = "0", 
                     side = "left" )

for( i in seq_along( ta$tract )){
  ta$tract[i] <- paste0( "36067", 
                         ta$tract[i], 
                         collapse = "" )
}

rm( i )

colnames( ta )[1] <- "GEOID" 

ta$GEOID <- as.character( ta$GEOID )
ta$month <- ymd( ta$month )
  
## Read in FIPS Codes to Filter

FIPS <- read.csv( ("~/CNYCF/Poverty Index/Simple Combine Script/Simple Combined Columns.csv") ) %>%
  select( GEOID )

FIPS <- as.character( FIPS$GEOID )

ta <- ta %>%
  filter( GEOID %in% FIPS )

rm( FIPS )

## Replace All NA Values with "0"

ta[ is.na( ta ) ] <- 0

#--------------------------------------------------------------#
# MONTHLY LEAD VIOLATIONS BY CENSUS TRACT

lead <- read.csv( "~/CNYCF/Poverty Index/Housing & Lead Script/lead_monthly_table.csv" )

lead$GEOID <- as.character( lead$GEOID )
lead$Month <- ymd( lead$Month )

colnames( lead ) <- c( "GEOID",
                       "month",
                       "lead" )

## Replace All NA Values with "0"

lead[ is.na( lead ) ] <- 0

#--------------------------------------------------------------#
# HOUSING DECLARED UNFIT

unfit <- read.csv( "~/CNYCF/Poverty Index/Housing & Lead Script/unfit_monthly_table.csv" )

unfit$GEOID <- as.character( unfit$GEOID )
unfit$Month <- ymd( unfit$Month )

colnames( unfit ) <- c( "GEOID",
                        "month",
                        "unfit" )

## Replace All NA Values with "0"

unfit[ is.na( unfit ) ] <- 0

#--------------------------------------------------------------#
# HOUSING VACANCIES

vacancies <- read.csv( "~/CNYCF/Poverty Index/Housing & Lead Script/vacancies_monthly_table.csv" )

vacancies$GEOID <- as.character( vacancies$GEOID )
vacancies$Month <- ymd( vacancies$Month )

colnames( vacancies ) <- c( "GEOID",
                            "month",
                            "vacant" )

## Replace All NA Values with "0"

vacancies[ is.na( vacancies ) ] <- 0

#--------------------------------------------------------------#
# HOUSING VIOLATIONS

violations <- read.csv( "~/CNYCF/Poverty Index/Housing & Lead Script/violations_monthly_table.csv" )

violations$GEOID <- as.character( violations$GEOID )
violations$Month <- ymd( violations$Month )

colnames( violations ) <- c( "GEOID",
                             "month",
                             "violations" )

## Replace All NA Values with "0"

violations[ is.na( violations ) ] <- 0

#--------------------------------------------------------------#
# MONTHLY CRIME BY TRACT (EXCLUDING LARCENY)

crime <- read.csv( "~/CNYCF/Poverty Index/crime_monthly_table.csv" )

crime$GEOID <- as.character( crime$GEOID )
crime$Month <- ymd( crime$Month )

colnames( crime ) <- c( "GEOID",
                        "month",
                        "crime" )

## Replace All NA Values with "0"

crime[ is.na( crime ) ] <- 0

#--------------------------------------------------------------#
# POPULATION IN WORKFORCE

workforce <- read_excel( "indicator_percents_example.xlsx" ) %>%
  select( GEOID,
          `Estimate; In the Labor Force Total: 18 to 64 years 2011-2015` )

colnames( workforce ) <- c( "GEOID",
                            "work_pop" )

workforce$GEOID <- as.character( workforce$GEOID )
workforce$work_pop <- as.integer( workforce$work_pop )

#--------------------------------------------------------------#
# MERGE POPULATIONS DATA

populations <- left_join( populations, workforce )

rm( workforce )

#--------------------------------------------------------------#
# MERGE REMAINING DATASETS

# Create Base Dataframe for All Merges Using "populations"

combined <- do.call( "rbind", 
                     replicate( length( unique( crime$month )), 
                                populations, 
                                simplify = FALSE ))

combined$month <- rep( x = unique( crime$month), each = 55 )

combined <- left_join( combined, crime )
combined <- left_join( combined, lead )
combined <- left_join( combined, qcew )
combined <- left_join( combined, ta )
combined <- left_join( combined, unemployment )
combined <- left_join( combined, unfit )
combined <- left_join( combined, vacancies )
combined <- left_join( combined, violations )

rm( crime,
    lead,
    qcew,
    ta,
    unemployment,
    unfit,
    vacancies,
    violations,
    populations )

## Rearrange Columns

combined <- combined %>%
  select( GEOID,
          month,
          total_pop,
          adult_pop,
          work_pop,
          crime,
          qcew,
          unemployed,
          temp_assist,
          violations,
          vacant,
          unfit,
          lead )

#--------------------------------------------------------------#
# SET NA VALUES to "0" FOR APPROPRIATE INDICATORS

combined$crime[ is.na( combined$crime ) ] <- 0
combined$unfit[ is.na( combined$unfit ) ] <- 0
combined$lead[ is.na( combined$lead ) ] <- 0

combined$violations[ is.na( combined$violations ) & combined$month >= date( "2017-01-01") ] <- 0
combined$vacant[ is.na( combined$vacant ) & combined$month >= date( "2017-01-01") & combined$month < date( "2017-02-01") ] <- 0

## Repeat "vacant" Count Throughout 2017

vac <- combined$vacant[ combined$month >= date( "2017-01-01") & combined$month < date( "2017-02-01") ]

combined$vacant[ combined$month >= date( "2017-02-01" ) ] <- 
  rep( x = vac, times = length( unique( combined$month[ combined$month >= date( "2017-02-01" ) ] )))

rm( vac )

#--------------------------------------------------------------#
# NORMALIZE ADDITIONAL INDICATORS (%) FROM FRANK'S PROTOTYPE

additional <- read_excel( "indicator_percents_example.xlsx" ) %>%
  select( GEOID,
          `Percent of Children Not Passing the 3rd grade ELA test 2016`,
          `SCSD 2017 3rd Grade ELA Percent Not Proficient`,
          `Percent of Children Lead Poisoned` )

colnames( additional ) <- c( "GEOID", 
                             "ela_fail_2016",
                             "ela_fail_2017",
                             "child_lead" )

additional <- additional[ 1:55, ]

# Repeat Values Over Months Throughout 2016, 2017

combined$ela_fail_prc[ combined$month >= date( "2016-01-01" ) & combined$month < date( "2017-01-01" ) ] <- 
  rep( x = additional$ela_fail_2016, times = 12 )

combined$ela_fail_prc[ combined$month >= date( "2017-01-01" ) & combined$month < date( "2018-01-01" ) ] <- 
  rep( x = additional$ela_fail_2017, times = 12 )

combined$child_lead_prc[ combined$month >= date( "2017-01-01" ) & combined$month < date( "2018-01-01" ) ] <- 
  rep( x = additional$child_lead, times = 12 )

rm( additional )

#--------------------------------------------------------------#
# ADDITION OF 2016 TOTAL RESIDENCES

residences <- read_excel( "~/CNYCF/Poverty Index/Poverty Index Datasets.xlsx", 
                          sheet = "Violations" , skip = 56, col_names = c( "tract",
                                                                           "GEOID",
                                                                           "year",
                                                                           "violations",
                                                                           "tot_homes" )) %>%
  select( GEOID,
          tot_homes )

combined$tot_homes[ combined$month >= date( "2016-01-01" ) & combined$month < date( "2018-01-01" ) ] <- 
  rep( x = residences$tot_homes, times = 24 )

rm( residences )

## Rearrange Columns

combined <- combined[, c(1:5, 16, 6:15 ) ]

#--------------------------------------------------------------#
# INSERT HUMAN-READABLE GEOID: "tract"

combined <- combined %>%
    mutate( tract = str_sub( string = GEOID,
                             start = 8,
                             end = 11 ))

combined$tract <- str_replace_all( combined$tract,
                                   pattern = "00$",
                                   replacement = "" ) # Pipe not working?

combined$tract <- gsub( x = combined$tract, 
                        pattern = "^(.{2})(.{2})$", 
                        replacement = "\\1\\.\\2" )

combined$tract <- as.character( combined$tract )

combined <- combined %>%
    select( GEOID, tract, month:child_lead_prc )

#--------------------------------------------------------------#
# INSERT MONTHLY TOTALS BEFOR CALCULATIONS

non_num <- combined[ , 1:3 ]  # Create data.frame of NA values
a = NA
b = NA
c = NA
na_vec <- data.frame( a, b, c, row.names = NULL )

non_num <- non_num %>%
    group_by( month ) %>%
    nest()

for (i in 1:nrow(non_num)){
    non_num$data[[i]] <- bind_rows( non_num$data[[i]], na_vec )
}                             # Preserve non-numeric values, append NA data.frame

non_num <- non_num %>%
    unnest() %>%
    ungroup() %>%
    select( month:tract )

rm( a, b, c, i, na_vec )

combined <- combined %>%
    group_by( month ) %>%
    nest()                    # Group by "month" and nest in list (purrr)

for (i in 1:nrow(combined)){
    combined$data[[i]] <- bind_rows( combined$data[[i]][,-c(1:2)], 
                                     colSums( combined$data[[i]][,-c(1:2)], 
                                              na.rm = TRUE ))
}                             # Take colSums() for numeric variables

combined <- combined %>%
    unnest()                  # Unnest and store in "combined"

rm( i )

# Merge datasets

combined <- bind_cols( non_num, combined ) %>%
    select( - month1 )

rm( non_num )

#--------------------------------------------------------------#
# NORMALIZING ELA SCORES 2016-2017

for ( i in 673:1344 ){
  combined$ela_fail_prc[ i ] <- combined$ela_fail_prc[ i ] * 100 
}

rm( i )

#--------------------------------------------------------------#
# COMPUTING PERCENTAGES AS NEW VARIABLES

combined <- combined %>%
  mutate( crime_prc = round( crime/( total_pop/100 ), digits = 3 ) * 100,
          qcew_prc = round( ( 11453 - qcew )/ 11453, digits = 3 ) * 100,
          unemp_prc = round( unemployed / work_pop, digits = 3 ) * 100,
          ta_prc = round( temp_assist / work_pop, digits = 3 ) * 100,
          viol_prc = round( violations / tot_homes, digits = 3 ) * 100,
          vacant_prc = round( vacant / tot_homes, digits = 3 ) * 100,
          unfit_prc = round( unfit / sum( unfit ), digits = 3 ) * 100,
          lead_prc = round( lead / sum( x = lead, na.rm = TRUE ), digits = 3 ) * 100,
          ela_fl_prc = round( ela_fail_prc * 1, 3 ),
          chd_lead_prc = round( child_lead_prc * 1, 3 ))

## Set Negative "qcew_per" Values to 0

for( i in seq_along( combined$qcew_prc )){
  if( !is.na(combined$qcew_prc[i]) & combined$qcew_prc[i] < 0 ){
    combined$qcew_prc[i] <- 0
  }
}

combined <- combined[ , -c( 16:17)]

rm( i )

combined <- combined %>%
  rowwise() %>%
  mutate( index = round( sum( crime_prc,
                              qcew_prc,
                              unemp_prc,
                              ta_prc,
                              viol_prc,
                              vacant_prc,
                              unfit_prc, 
                              lead_prc, 
                              ela_fl_prc,
                              chd_lead_prc,
                              na.rm = TRUE ), 3 ))

#--------------------------------------------------------------#
# RENAME "NA" Value in "GEOID" to "total"; "tract" to "city"

for ( i in seq_along( combined$GEOID )){
    if( is.na( combined$GEOID[i] ) ){
        combined$GEOID[i] <- "All"
    }
}

for ( i in seq_along( combined$tract )){
    if( is.na( combined$tract[i] ) ){
        combined$tract[i] <- "All"
    }
}

rm( i )

#--------------------------------------------------------------#
# TEST: SET RANGE TO OCTOBER - DECEMBER, 2017

write.csv( combined, "index_percentages.csv" )

