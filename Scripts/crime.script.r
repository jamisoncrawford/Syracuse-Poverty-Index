
###--------------------------------------------------------------### 
### CLEAN CRIME DATA

# Built with RStudio v. 1.1.414

RStudio.Version()

# DESCRIPTION: Preps "Crime" data based on Syracuse.com format & geocodes by Census Tract.

#--------------------------------------------------------------#
# CLEAR LIBRARY; INSTALL & LOAD PACKAGES

rm( list = ls() )

if( !require( dplyr ) ) { install.packages( "dplyr" ) }
if( !require( readxl ) ) { install.packages( "readxl" ) }
if( !require( censusr ) ) { install.packages( "censusr" ) }
if( !require( stringr ) ) { install.packages( "stringr" ) }
if( !require( lubridate ) ) { install.packages( "lubridate" ) }

library( dplyr )
library( readxl )
library( censusr )
library( stringr )
library( lubridate )

#--------------------------------------------------------------#
# SET WORKING DIRECTORY & READ IN DATA

setwd( "~/CNYCF/Poverty Index" )

crime <- read.csv( file = "https://raw.githubusercontent.com/cnycf/cnydata/master/Poverty%20Index/Crime%20Data.csv" )

#--------------------------------------------------------------#
# RENAME COLUMNS & REMOVE "TIME" & "AGENCY" COLUMNS

colnames( crime ) <- c( "Crime" ,
                        "Address" ,
                        "City" ,
                        "Agency" ,
                        "Date" ,
                        "Time" )

crime <- crime[ , -c( 4 , 6 ) ]

#--------------------------------------------------------------#
# REMOVE "BLOCK", DELETE WHITESPACE, REPLACE "E" (EAST) & "N" (NORTH)

crime$Address <- gsub( x = crime$Address , 
                       pattern = "block " , 
                       replacement = "" )

crime$Address <- str_replace_all( crime$Address , " +" , " " )

crime$City <- str_replace_all( string = crime$City , 
                               pattern = "E Syracuse" , 
                               replacement = "East Syracuse" )

crime$City <- str_replace_all( string = crime$City , 
                               pattern = "N Syracuse" , 
                               replacement = "North Syracuse" )

#--------------------------------------------------------------#
# COERCE "DATE" TO POSIX CLASS, CREATE "STATE" & "PERIOD" VARIABLES

crime$Date <- mdy( crime$Date )

crime <- crime %>%
  mutate( "State" = "NY" ) %>%
  mutate( "Period" = Date )

#--------------------------------------------------------------#
# REORDER COLUMNS & FORMAT/COERCE "PERIOD"

crime <- crime[ , c( 4 , 6 , 1:3 , 5 ) ]

crime$Period <- format( as.Date( crime$Period ) , "%m-%Y")

#--------------------------------------------------------------#
# CREATE "FULL" (ADDRESS) VARIABLE

crime$Full <- paste( crime$Address , 
                     crime$City, 
                     crime$State , 
                     sep = ", " )

#--------------------------------------------------------------#
# PREPARE FOR CENSUS GEOCODER & READ IN GEOCODED DATA

# https://geocoding.geo.census.gov/geocoder/locations/addressbatch?form 

geocode <- crime[ 4:6 ]

geocode$ID <- 1:length( crime$Address )
geocode$Zip <- NA
geocode <- geocode %>% 
  select( ID ,
          Address ,
          City, 
          State ,
          Zip )

write.csv( x = geocode , 
           file = "Crime.Geocoder.csv" )

geocode <- read_xls( "C:/Users/Jamison/Downloads/GeocodeResults.xls" )

#--------------------------------------------------------------#
# REORDER & MERGED CENSUS TRACTS ("GEOID") BY UNIQUE ID; REDUCE COLUMNS

geocode$`RECORD ID NUMBER` <- as.numeric( geocode$`RECORD ID NUMBER` )

geocode <- geocode[ order( geocode$`RECORD ID NUMBER` , decreasing = FALSE) , ]

geocode <- geocode[ 1:length( crime$Full ) , ]

crime$GEOID <- with( geocode , 
                     paste0( geocode$`STATE CODE` , 
                             geocode$`COUNTY CODE` , 
                             geocode$`TRACT CODE` ) )

crime <- crime[ !grepl( "NANANA", crime$GEOID ) , ]

crime <- crime %>% 
  select( GEOID , 
          Date ,
          Period ,
          Crime )

rm( geocode )

#--------------------------------------------------------------#
# KEEP IF MATCHES 55 CENSUS TRACTS

GEOID <- read.csv( "Simple Combine Script/Simple Combined Columns.csv" ) %>%
  select( GEOID )

GEOID <- GEOID$GEOID

crime <- crime[ which( crime$GEOID %in% GEOID ) , ]

table <- count( crime , GEOID )

colnames( table ) <- c( "GEOID" ,
                        "Value" )

table$Date <- ymd( "2018-02-01" )
table$Indicator <- "CRM"
table$Source <- "Syr.com"

table <- table %>%
  select( GEOID , 
          Source , 
          Indicator , 
          Date , 
          Value )

rm( GEOID ,
    crime )

#--------------------------------------------------------------#
# WRITE TO .CSV

write.csv( x = table , 
           file = "Crime.Clean.csv" , 
           row.names = FALSE )






