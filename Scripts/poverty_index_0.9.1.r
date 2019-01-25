
###--------------------------------------------------------------### 
### POVERTY INDEX MERGE & TIDY SCRIPT

# Index Version 0.9.1
# R v. 3.5.1
# RStudio v. 1.1.456
# Updated: 2019-01-16

# DESCRIPTION: Format, merge, and tidy all Poverty Index data

#--------------------------------------------------------------#
# CLEAR LIBRARY; INSTALL & LOAD PACKAGES

rm(list = ls())

if(!require(tidyr)){install.packages("tidyr")}
if(!require(dplyr)){install.packages("dplyr")}
if(!require(purrr)){install.packages("purrr")}
if(!require(readr)){install.packages("readr")}
if(!require(scales)){install.packages("scales")}
if(!require(readxl)){install.packages("readxl")}
if(!require(stringr)){install.packages("stringr")}
if(!require(reshape2)){install.packages("reshape2")}
if(!require(lubridate)){install.packages("lubridate")}
if(!require(data.table)){install.packages("data.table")}

library(tidyr)
library(dplyr)
library(purrr)
library(readr)
library(scales)
library(readxl)
library(stringr)
library(reshape2)
library(lubridate)
library(data.table)

#--------------------------------------------------------------#
# READ IN & FORMAT TABLES

setwd("~/CNYCF/Poverty Index/Percentage Prototype Versions")

sets <- "Poverty Index Datasets 0.9.1.xlsx"
ccdi <- c("text", "text", "date", "numeric")
shts <- c("UI Beneficiaries", "TA Individuals", "TA Cases", "Mean Wage", 
          "Vacancies", "Crime", "Larceny", "Population", "Adult Population", 
          "Working Population", "Improved Parcels", "All Failed ELA", 
          "Poverty Failed ELA", "Child Lead")

uibn <- read_xlsx(sets, sheet = shts[1], col_types = ccdi)
tain <- read_xlsx(sets, sheet = shts[2], col_types = ccdi)
tacs <- read_xlsx(sets, sheet = shts[3], col_types = ccdi)
wage <- read_xlsx(sets, sheet = shts[4], col_types = ccdi)
vacn <- read_xlsx(sets, sheet = shts[5], col_types = ccdi)
crim <- read_xlsx(sets, sheet = shts[6], col_types = ccdi)
larc <- read_xlsx(sets, sheet = shts[7], col_types = ccdi)
tpop <- read_xlsx(sets, sheet = shts[8], col_types = ccdi)
apop <- read_xlsx(sets, sheet = shts[9], col_types = ccdi)
wpop <- read_xlsx(sets, sheet = shts[10], col_types = ccdi)
prop <- read_xlsx(sets, sheet = shts[11], col_types = ccdi)
fela <- read_xlsx(sets, sheet = shts[12], col_types = ccdi)
pela <- read_xlsx(sets, sheet = shts[13], col_types = ccdi)
chld <- read_xlsx(sets, sheet = shts[14], col_types = ccdi)
rm(sets, shts, ccdi)

#--------------------------------------------------------------#
# MERGE DATSETS: TIDY (LONG) & SPREAD (WIDE)

inds <- bind_rows(prop, crim, larc, tacs, tain, uibn, vacn, wage, fela, pela, chld) %>%
    mutate(indicator = tolower(indicator),
           date = floor_date(date, "month")) %>%
    select(date, geoid:count) %>%
    arrange(date, geoid)                           # Bind rows, i.e. long format

rm(prop, crim, larc, tacs, tain, uibn, vacn, wage, fela, pela, chld)

miss <- dcast(data = setDT(inds), 
              formula = date + geoid ~ indicator,
              fun.aggregate = length,
              value.var = c("count"))              # Determine true NA positions
miss[ miss == 0 ] <- -1

tidy <- dcast(data = setDT(inds), 
              formula = date + geoid ~ indicator,
              fun.aggregate = sum,
              value.var = c("count"))              # Spread by indicator columns

miss <- as.data.frame(miss)
tidy <- as.data.frame(tidy)

for(i in 1:ncol(tidy)){
    for(j in 1:nrow(tidy)){
        if(miss[j,i] == -1){
            tidy[j,i] <- NA }}}                    # Filter true NAs by position

rm(i, j, miss, inds)

nums <- sapply(tidy, is.numeric)                   # Set rounding to 3 digits
tidy[nums] <- lapply(tidy[nums], round, digits = 3); rm(nums)

#--------------------------------------------------------------#
# DUPLICATE POPULATION VALUES IN ALL GEOIDS/MONTHS

first <- floor_date(as.POSIXlt(min(unique(tidy$date))), "year")
last <- ceiling_date(as.POSIXlt(max(unique(tidy$date))), "year")
dates <- seq(first, last, by = "month")
n <- length(dates)

pops <- data_frame(date = rep(dates, each = 55),
                              geoid = rep(tpop$geoid, n)) %>%
    mutate(tpop = rep(tpop$count, n),
           apop = rep(apop$count, n),
           wpop = rep(wpop$count, n))

tidy <- left_join(pops, tidy) %>%
    select(date:wpop, prop, crim, larc, chlp:vac)

rm(first, last, dates, n, apop, tpop, wpop, pops)

#--------------------------------------------------------------#
# SET MISSING VALUES TO 0: CRIM, LARC

start <- min(unique(tidy$date[!is.na(tidy$crim)]))
finish <- max(unique(tidy$date[!is.na(tidy$crim)]))

for (i in 1:nrow(tidy)){
    if (is.na(tidy$crim[i]) & tidy$date[i] >= start & tidy$date[i] <= finish){
        tidy$crim[i] <- 0}
    if(is.na(tidy$larc[i]) & tidy$date[i] >= start & tidy$date[i] <= finish){
        tidy$larc[i] <- 0}}; rm(start, finish)

#--------------------------------------------------------------#
# DUPLICATE MONTHLY VALUES ACROSS QUARTERS: PROP, VAC, QCEW

wcap <- max(unique(tidy$date[!is.na(tidy$qcew)])) + period(2, "month")
pcap <- max(unique(tidy$date[!is.na(tidy$prop)])) + period(2, "month")
vcap <- max(unique(tidy$date[!is.na(tidy$vac)])) + period(2, "month")

for (i in 1:(nrow(tidy) - 55)){
    if (!is.na(tidy$qcew[i]) & is.na(tidy$qcew[i+55]) & tidy$date[i] < wcap){
        tidy$qcew[i+55] <- tidy$qcew[i]}
    if (!is.na(tidy$prop[i]) & is.na(tidy$prop[i+55]) & tidy$date[i] < pcap){
        tidy$prop[i+55] <- tidy$prop[i]}
    if (!is.na(tidy$vac[i]) & is.na(tidy$vac[i+55]) & tidy$date[i] < vcap){
        tidy$vac[i+55] <- tidy$vac[i]}
}
rm(i, wcap, pcap, vcap)

#--------------------------------------------------------------#
# DUPLICATE MONTHLY VALUES ACROSS YEARS: CHLP, FELA, PELA

cap <- max(unique(tidy$date[!is.na(tidy$fela)])) + period(1, "year")
yrs <- length(unique(as.Date(floor_date(x = tidy$date, unit = "year"))))

for (j in 1:55){
  for (i in seq(j, by = 660, length.out = yrs)){
    if (!is.na(tidy$fela[i]) & tidy$date[i] < cap){
        tidy[seq(i, by = 55, length.out = 12), "fela"] <- tidy$fela[i]}
    if (!is.na(tidy$pela[i]) & tidy$date[i] < cap){
        tidy[seq(i, by = 55, length.out = 12), "pela"] <- tidy$pela[i]} 
    if (!is.na(tidy$chlp[i]) & tidy$date[i] < cap){
        tidy[seq(i, by = 55, length.out = 12), "chlp"] <- tidy$chlp[i]} 
  }
}

tidy$fela[tidy$date == ymd(cap)] <- NA
tidy$pela[tidy$date == ymd(cap)] <- NA
tidy$chlp[tidy$date == ymd(cap)] <- NA

rm(i, j, cap, yrs)

#--------------------------------------------------------------#
# MONTHLY TOTALS

base <- tidy %>% select(date:geoid)
null <- data.frame(a = NA, b = NA, row.names = NULL)

base <- base %>% group_by(date) %>% nest()
for (i in 1:nrow(base)){base$data[[i]] <- bind_rows(base$data[[i]], null)}
base <- base %>% unnest() %>% ungroup() %>% select(date:geoid)
rm(i, null)

tidy <- tidy %>% group_by(date) %>% nest()
for (i in 1:nrow(tidy)){
    tidy$data[[i]] <- bind_rows(tidy$data[[i]][,-1], 
                                colSums(tidy$data[[i]][,-1], 
                                        na.rm = TRUE ))}

tidy <- tidy %>% unnest()
tidy <- bind_cols(base, tidy) %>% select(-date1)

for ( i in 1:nrow(tidy)){
    if( is.na( tidy$geoid[i] ) ){
        tidy$geoid[i] <- "monthly_total"}}; rm(i, base)

#--------------------------------------------------------------#
# MONTHLY TOTAL CORRECTIONS: ELA FAILURE, ELA FAILURE POVERTY, QCEW, & CHILD LEAD LEVELS

sets <- "Poverty Index Datasets 0.9.1.xlsx"
type <- c("text", "date", "numeric")
shts <- c("Failed ELA Totals", "Child Lead Totals", "Failed ELA Poverty Totals", "City Wage")

elat <- read_xlsx(sets, sheet = shts[1], col_types = type)
chlt <- read_xlsx(sets, sheet = shts[2], col_types = type)
elap <- read_xlsx(sets, sheet = shts[3], col_types = type)
wsyr <- read_xlsx(sets, sheet = shts[4], col_types = type)
rm(sets, type, shts)

tidy$qcew[tidy$geoid == "monthly_total"] <- NA
tidy$fela[tidy$date <= ymd("2016-12-31") & tidy$geoid == "monthly_total"] <- NA
tidy$pela[tidy$date <= ymd("2017-12-31") & tidy$geoid == "monthly_total"] <- NA

tidy$fela[tidy$date >= ymd("2017-01-01") & tidy$date <= ymd("2017-12-31") & tidy$geoid == "monthly_total"] <- rep(elat$count[1], 12)
tidy$fela[tidy$date >= ymd("2018-01-01") & tidy$date <= ymd("2018-12-31") & tidy$geoid == "monthly_total"] <- rep(elat$count[2], 12)
tidy$pela[tidy$date >= ymd("2017-01-01") & tidy$date <= ymd("2017-12-31") & tidy$geoid == "monthly_total"] <- rep(elap$count[1], 12)
tidy$pela[tidy$date >= ymd("2018-01-01") & tidy$date <= ymd("2018-12-31") & tidy$geoid == "monthly_total"] <- rep(elap$count[2], 12)

tidy$chlp[tidy$date >= ymd("2015-01-01") & tidy$date <= ymd("2018-12-31") & tidy$geoid == "monthly_total"] <- rep(chlt$count[2:5], each = 12)

tidy$qcew[tidy$date >= ymd("2016-07-01") & 
            tidy$date <= ymd("2018-03-01") & 
            tidy$geoid == "monthly_total"] <- rep(wsyr$count, each = 3)

rm(chlt, elat, elap, wsyr)

#--------------------------------------------------------------#
# PERCENTAGES FORMULA

tidy <- tidy %>%
    mutate(child_lead_aprc   = round(chlp, 3),
           crime_mprc        = round(crim / (tpop / 100), 3) * 100,
           ela_fail_aprc     = round(fela/10, 3 ),
           ela_pov_fail_aprc = round(pela/10, 3 ),
           larceny_mprc      = round(larc / (tpop / 100), 3) * 100,
           wages_qprc        = round((12847 - qcew) / 12847, 3) * 100,
           ta_case_mprc      = round(tac / wpop, 3) * 100,
           ta_inds_mprc      = round(tai / wpop, 3) * 100,
           unemployment_mprc = round(uib / wpop, 3) * 100,
           vacancy_qprc      = round(vac / prop, 3) * 100)

for(i in seq_along(tidy$wages_qprc)){
  if(!is.na(tidy$wages_qprc[i]) & tidy$wages_qprc[i] < 0 ){
    tidy$wages_qprc[i] <- 0}}; rm( i )

tidy <- tidy %>% rowwise() %>%
    mutate(index = round(sum(child_lead_aprc, crime_mprc, ela_pov_fail_aprc,
                             larceny_mprc, wages_qprc, ta_case_mprc, 
                             unemployment_mprc, vacancy_qprc, 
                             na.rm = TRUE ), 3 ))

#--------------------------------------------------------------#
# MODIFY MONTHLY TOTALS WITH MISSING DATA

tidy$vacancy_qprc[tidy$geoid == "monthly_total" & tidy$vacancy_qprc == "NaN"] <- NA

for (i in 1:nrow(tidy)){
  if (tidy$geoid[i] == "monthly_total")
    for (j in c(1:21, 23:27)){                        # MUST MANUALLY CHANGE IF VARS ADDED: EXCLUDE "WAGES_QPRC"
      if (tidy[i,j] == 0 & !is.na(tidy[i,j])){
        tidy[i,j] <- NA }}}

rm(i, j)

#--------------------------------------------------------------#
# RENAME "montly_totals": "city_wide"

tidy$geoid[tidy$geoid == "monthly_total"] <- "City"

#--------------------------------------------------------------#
# TRANSFORM "geoid" VARIABLE: "tract"

tidy <- tidy %>%
  mutate(tract = str_sub(geoid, 7, 11),
         tract = paste(str_sub(tract, 1, 3), 
                       ".", 
                       str_sub(tract, 4, 5), 
                       sep = ""),
         tract = str_remove(tract, 
                            pattern = "^0+"))

for (i in seq_along(tidy$tract)){             # Name Change: "City" ***
  if (tidy$geoid[i] == "City"){
    tidy$tract[i] <- "City"
  }
}

tidy <- tidy %>% 
  select(date:geoid, tract, tpop:index)

#--------------------------------------------------------------#
# REMOVE NA VALUES

for (i in 1:nrow(tidy)){
  for (j in 1:ncol(tidy)){
    if (is.na(tidy[i, j])){
      tidy[i, j] <- ""
    }
  }
}

rm(i, j)

#--------------------------------------------------------------#
# VARIABLE RENAMING (OPTIONAL)

vars <- c("Month", "GEOID", "Tract", "Total Pop.", "Adult Pop.", "Working Pop.", 
          "Properties", "Crime, No Larceny", "Crime, Larceny Only", "Child Lead Perc.", 
          "Failed ELA Perc.", "Failed ELA in Poverty", "Mean Qrt. Wage", "Temp. Assist Cases", 
          "Temp. Assist Individuals", "Unemployed", "Vacancies", "Child Lead Poison Rate", 
          "Other Crime per Capita", "G3 ELA Failure Rate", "ELA Failure Rate, Impoverished", 
          "Larceny per Capita", "Mean Wages v. County", "Temp. Assist Cases per Working Population", 
          "Temp. Assist Individuals per Working Population", "Unemployed Population", "Parcels with Vacancies", "Index Score")

colnames(tidy) <- vars

rm(vars)

#--------------------------------------------------------------#
# WRITE TO .CSV: INDEX, REDACTED INDEX

tidy$Month <- as.character(tidy$Month)

write_csv(tidy, "index_0.9.1.csv")

tidy %>% select(Month:Properties, `Child Lead Poison Rate`:`Index Score`) %>%
  write_csv("index_0.9.1_redact.csv")

#--------------------------------------------------------------#
# TIDY REDACTED INDEX

tidier <- tidy %>%
  gather(key = Indicator, 
         value = Value, 
         `Total Pop.`:`Index Score`)

write_csv(tidier, "index_0.9.1_tidy.csv")

tidiest <- tidy %>%
  select(Month:Tract, `Child Lead Poison Rate`:`Index Score`) %>%
  gather(key = Indicator,
         value = Percent, 
         `Child Lead Poison Rate`:`Index Score`)

write_csv(tidiest, "index_0.9.1_tidy_percents.csv")

tidy_raw <- tidy %>%
  select(Month:Vacancies) %>%
  gather(key = Indicator,
         value = Count,
         `Total Pop.`:Vacancies)

write_csv(tidy_raw, "index_0.9.1_tidy_raw.csv")

