
###--------------------------------------------------------------### 
### POVERTY INDEX CHOROPLETH MAP

# Built with RStudio v. 1.1.414

RStudio.Version()

# DESCRIPTION: Visualizes Poverty Index Scores via choropleth maps for 55 Syracuse Census Tracts.

#--------------------------------------------------------------#
# CLEAR LIBRARY; INSTALL & LOAD PACKAGES

rm( list = ls() )

if( !require( sf ) ) { install.packages( "sf" ) }
if( !require( tmap ) ) { install.packages( "tmap" ) }
if( !require( ggmap ) ) { install.packages( "ggmap" ) }
if( !require( dplyr ) ) { install.packages( "dplyr" ) }
if( !require( tigris ) ) { install.packages( "tigris" ) }

library( sf )
library( tmap )
library( ggmap )
library( dplyr )
library( tigris )

#--------------------------------------------------------------#
# SET WORKING DIRECTORY, READ IN INDEX, & REDUCE COLUMNS

setwd( "~/CNYCF/Poverty Index/Mapping Script" )

Index <- read.csv( "https://raw.githubusercontent.com/cnycf/cnydata/master/Poverty%20Index/Scoring%20Script%20-%20Indices/Index.csv" ) %>%
  select( GEOID ,
          Q.QCEW , 
          Q.CRM ,
          Q.TAI ,
          Q.VIO ,
          Q.VAC ,
          Q.UIB ,
          Index )

Index$GEOID <- as.character( Index$GEOID )
Index$Q.VAC <- as.numeric( Index$Q.VAC )

#--------------------------------------------------------------#
# LOAD CENSUS TRACT SHAPEFILES AS SIMPLE FEATURES, FILTER BY TRACTS, & MERGE SCORES

Tracts <- tracts( state = "NY" , 
                  county = "Onondaga" , 
                  year = 2016 , 
                  class = "sf" ) %>%
  filter( GEOID %in% Index$GEOID ) %>%
  select( GEOID ,
          NAME ) %>%
  inner_join( Index )

#--------------------------------------------------------------#
# DRAW & WRITE STATIC CHOROPLETH OF INDEX SCORES

tm_shape(Tracts) +
  tm_fill( col = "Index" ,
           title = "Severity" ) +
  tm_borders( col = "white" ,
              lwd = 1.5 ) +
  tm_text( text = "NAME" , size = 0.4 ) +
  tm_credits( text = "Accessed via Tigris & Tmap Packages \nSource: ACS, DOL, DSS, SNBD, Syracuse.com" , 
              align = "left" , 
              position = c( "left" , "bottom" ) ,
              size = 0.4 ) +
  tm_layout( title = "Syracuse Poverty Index" , 
             title.size = 1 , 
             title.position = c( "right" , "top" ) , 
             legend.title.size = 1 , 
             frame = FALSE )

save_tmap( filename = "poverty_map.png" )

#--------------------------------------------------------------#
# DRAW, WRITE, & VIEW INTERACTIVE CHOROPLETH OF INDEX SCORES

tm_shape(Tracts) +
  tm_fill( col = "Index" ,
           title = "Severity" ,
           pallette = "OrRd" ) +
  tm_borders( col = "white" ,
              lwd = 1.5 ) +
  tm_text( text = "NAME" , 
           size = 0.75 , 
           col = "grey35" ) +
  tm_credits( text = "Accessed via Tigris & Tmap Packages \nSource: ACS, DOL, DSS, SNBD, Syracuse.com" , 
              align = "left" , 
              position = c( "left" , "bottom" ) ,
              size = 0.4 ) +
  tm_layout( title = "Syracuse Poverty Index" , 
             title.size = 1 , 
             title.position = c( "right" , "top" ) , 
             legend.title.size = 1 , 
             frame = FALSE )

tmap_mode( "view" )
last_map()

save_tmap( filename = "poverty_map.html" )
