
###--------------------------------------------------------------### 
### POVERTY INDEX SCORE CONVERSION

# Built with RStudio v. 1.1.414

RStudio.Version()

# DESCRIPTION: Convert Poverty Index values to scores per agreed on conventions

#--------------------------------------------------------------#
# CLEAR LIBRARY; INSTALL & LOAD PACKAGES

rm( list = ls() )

if( !require( dplyr ) ) { install.packages( "dplyr" ) }
if( !require( readxl ) ) { install.packages( "readxl" ) }

library( dplyr )
library( readxl )

#--------------------------------------------------------------#
# SET WORKING DIRECTORY & READ IN TABLES

setwd( "~/CNYCF/Poverty Index/Scoring Script" )

index <- read.csv( "~/CNYCF/Poverty Index/Simple Combine Script/Quart Combined Columns.csv" )

#--------------------------------------------------------------#
# CREATE NEW VARIABLES: PERCENTAGES, INDICATOR VALUE / APPROPRIATE POPULATION

index <- index %>% mutate( TAI.PCT = X2018.Q1.TAI / X2015.Q1.TPOP )
index <- index %>% mutate( VIO.PCT = X2016.Q1.VIO / X2016.Q1.RES )
index <- index %>% mutate( VAC.PCT = X2016.Q1.VAC / X2016.Q1.RES )
index <- index %>% mutate( UIB.PCT = X2018.Q1.UIB / X2015.Q1.APOP )

#--------------------------------------------------------------#
# BIN VALUES BY QUINTILE & SUM FOR INDEX

index <- index %>% mutate( Q.QCEW = cut( x = index$X2017.Q3.WAG , breaks = 5 , labels = 0:4 ) )
index <- index %>% mutate( Q.CRM = cut( x = index$X2018.Q1.CRM , breaks = 5 , labels = 0:4 ) )
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

# Revert to Original Column Names

colnames( index )[1:11] <- colnames( read.csv( "~/CNYCF/Poverty Index/Simple Combine Script/Quart Combined Columns.csv" , check.names = FALSE) )

#--------------------------------------------------------------#
# WRITE TO .CSV

write.csv( x = index , 
           file = "Quartery Index.csv" )






