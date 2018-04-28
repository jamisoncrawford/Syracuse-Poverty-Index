
###--------------------------------------------------------------### 
### POVERTY INDEX SCORE CONVERSION

# Built with RStudio v. 1.1.414

RStudio.Version()

# DESCRIPTION: Convert Poverty Index values to scores per agreed on conventions

#--------------------------------------------------------------#
# CLEAR LIBRARY; INSTALL & LOAD PACKAGES

rm( list = ls() )

if( !require( zoo ) ) { install.packages( "zoo" ) }
if( !require( dplyr ) ) { install.packages( "dplyr" ) }
if( !require( readxl ) ) { install.packages( "readxl" ) }

library( zoo )
library( dplyr )
library( readxl )

#--------------------------------------------------------------#
# SET WORKING DIRECTORY & READ IN TABLES

setwd( "~/CNYCF/Poverty Index/Scoring Script" )

index <- read.csv( "~/CNYCF/Poverty Index/Simple Combine Script/Simple Combined Columns.csv" )

#--------------------------------------------------------------#
# REVERT COLUMN NAMES

colnames( index ) <- colnames( read.csv( "~/CNYCF/Poverty Index/Simple Combine Script/Simple Combined Columns.csv" , check.names = FALSE) )

#--------------------------------------------------------------#
# CREATE NEW VARIABLES: PERCENTAGES, INDICATOR VALUE / APPROPRIATE POPULATION

index <- index %>% mutate( TAI.PCT = `2018-03-07 TAI` / `2015-01-01 TPOP` )
index <- index %>% mutate( VIO.PCT = `2016-01-01 VIO` / `2016-01-01 RES` )
index <- index %>% mutate( VAC.PCT = `2016-01-01 VAC` / `2016-01-01 RES` )
index <- index %>% mutate( UIB.PCT = `2018-02-01 UIB` / `2015-01-01 APOP` )

#--------------------------------------------------------------#
# BIN VALUES BY QUINTILE & SUM FOR INDEX

index <- index %>% mutate( Q.QCEW = cut( x = index$`2017-09-01 QCEW` , breaks = 5 , labels = 0:4 ) )
index <- index %>% mutate( Q.CRM = cut( x = index$`2018-02-01 CRM` , breaks = 5 , labels = 0:4 ) )
index <- index %>% mutate( Q.TAI = cut( x = index$TAI.PCT , breaks = 5 , labels = 0:4 ) )
index <- index %>% mutate( Q.VIO = cut( x = index$VIO.PCT , breaks = 5 , labels = 0:4 ) )
index <- index %>% mutate( Q.VAC = cut( x = index$VAC.PCT , breaks = 5 , labels = 0:4 ) )
index <- index %>% mutate( Q.UIB = cut( x = index$UIB.PCT , breaks = 5 , labels = 0:4 ) )

index$Q.QCEW <- as.numeric( index$Q.QCEW )
index$Q.CRM <- as.numeric( index$Q.CRM )
index$Q.TAI <- as.numeric( index$Q.TAI )
index$Q.VIO <- as.numeric( index$Q.VIO )
index$Q.VAC <- as.numeric( index$Q.VAC )
index$Q.UIB <- as.numeric( index$Q.UIB )

#--------------------------------------------------------------#
# REPLACE MISSING SCORES WITH AVERAGE INDICATOR SCORES

index$Q.QCEW <- round( x = na.aggregate( object = index$Q.QCEW , by = mean ) , digits = 2 )
index$Q.CRM <- round( x = na.aggregate( object = index$Q.CRM , by = mean ) , digits = 2 )
index$Q.TAI <- round( x = na.aggregate( object = index$Q.TAI , by = mean ) , digits = 2 )
index$Q.VIO <- round( x = na.aggregate( object = index$Q.VIO , by = mean ) , digits = 2 )
index$Q.VAC <- round( x = na.aggregate( object = index$Q.VAC , by = mean ) , digits = 2 )
index$Q.UIB <- round( x = na.aggregate( object = index$Q.UIB , by = mean ) , digits = 2 )

#--------------------------------------------------------------#
# TOTAL SCORES & CREATE FINAL INDEX COLUMN

index <- index %>% 
  group_by( GEOID ) %>% 
  summarize_all( sum ) %>% mutate( Index = Q.QCEW + Q.CRM + Q.TAI + Q.VIO + Q.VAC + Q.UIB )

#--------------------------------------------------------------#
# WRITE TO .CSV

write.csv( x = index , 
           file = "Index.csv" )







