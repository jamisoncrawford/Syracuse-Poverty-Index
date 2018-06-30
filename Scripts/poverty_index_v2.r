
###--------------------------------------------------------------### 
### POVERTY INDEX MERGE & TIDY SCRIPT

# R v. 3.5.0
# RStudio v. 1.1.453

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

setwd("~/CNYCF/Poverty Index/Simple Combine Script")

sets <- "~/CNYCF/Poverty Index/Poverty Index Datasets.xlsx"
ccdi <- c("text", "text", "date", "numeric")
shts <- c("UI Beneficiaries", "TA Individuals", "TA Cases", "Mean Wage", 
          "Vacancies", "Violations", "Crime", "Larceny", "Population", 
          "Adult Population", "Working Population", "Properties", "Failed ELA", 
          "Child Lead", "Lead Violations", "Unfit Housing")

uibn <- read_xlsx(sets, sheet = shts[1], col_types = ccdi)
tain <- read_xlsx(sets, sheet = shts[2], col_types = ccdi)
tacs <- read_xlsx(sets, sheet = shts[3], col_types = ccdi)
wage <- read_xlsx(sets, sheet = shts[4], col_types = ccdi)
vacn <- read_xlsx(sets, sheet = shts[5], col_types = ccdi)
viol <- read_xlsx(sets, sheet = shts[6], col_types = ccdi)
crim <- read_xlsx(sets, sheet = shts[7], col_types = ccdi)
larc <- read_xlsx(sets, sheet = shts[8], col_types = ccdi)
tpop <- read_xlsx(sets, sheet = shts[9], col_types = ccdi)
apop <- read_xlsx(sets, sheet = shts[10], col_types = ccdi)
wpop <- read_xlsx(sets, sheet = shts[11], col_types = ccdi)
prop <- read_xlsx(sets, sheet = shts[12], col_types = ccdi)
fela <- read_xlsx(sets, sheet = shts[13], col_types = ccdi)
chld <- read_xlsx(sets, sheet = shts[14], col_types = ccdi)
lead <- read_xlsx(sets, sheet = shts[15], col_types = ccdi)
nfit <- read_xlsx(sets, sheet = shts[16], col_types = ccdi)
rm(sets, shts, ccdi)

#--------------------------------------------------------------#
# MERGE DATSETS: TIDY (LONG) & SPREAD (WIDE)

inds <- bind_rows(crim, larc, tacs, tain, uibn, vacn, 
                  viol, wage, fela, chld, lead, nfit) %>%
    mutate(indicator = tolower(indicator),
           date = floor_date(date, "month")) %>%
    select(date, geoid:count) %>%
    arrange(date, geoid)                           # Bind rows, i.e. long format

rm(crim, larc, tacs, tain, uibn, vacn, viol, wage, fela, chld, lead, nfit)

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

#--------------------------------------------------------------#
# DUPLICATE POPULATION & PROPERTY VALUES IN ALL GEOIDS/MONTHS

n <- length(unique(tidy$date))
pops <- data_frame(date = rep(unique(tidy$date), each = 55),
                              geoid = rep(tpop$geoid, n)) %>%
    mutate(tpop = rep(tpop$count, n),
           apop = rep(apop$count, n),
           wpop = rep(wpop$count, n),
           prop = rep(prop$count[56:110], n))

tidy <- left_join(pops, tidy)

rm(apop, tpop, wpop, prop, pops, n)

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
# DUPLICATE MONTHLY VALUES ACROSS QUARTERS: QCEW

cap <- max(unique(tidy$date[!is.na(tidy$qcew)])) + period(2, "month")

for (i in 1:(nrow(tidy) - 55)){
    if (!is.na(tidy$qcew[i]) & is.na(tidy$qcew[i+55]) & tidy$date[i] < cap){
        tidy$qcew[i+55] <- tidy$qcew[i]}
}
rm(i, cap)

#--------------------------------------------------------------#
# DUPLICATE MONTHLY VALUES ACROSS YEARS: CHLP, FELA, LEAD, NFIT, VAC, VIOL

cap <- max(unique(tidy$date[!is.na(tidy$fela)])) + period(1, "year")

for (i in 1:nrow(tidy)){
    if (!is.na(tidy$fela[i]) & is.na(tidy$fela[i+55]) & tidy$date[i] < cap){
        tidy$fela[seq(i, by = 55, length.out = 12)] <- tidy$fela[i]} 
    if (!is.na(tidy$chlp[i]) & is.na(tidy$chlp[i+55]) & tidy$date[i] < cap){
        tidy$chlp[seq(i, by = 55, length.out = 12)] <- tidy$chlp[i]} 
    if (!is.na(tidy$lead[i]) & is.na(tidy$lead[i+55]) & tidy$date[i] < cap){
        tidy$lead[seq(i, by = 55, length.out = 12)] <- tidy$lead[i]} 
    if (!is.na(tidy$nfit[i]) & is.na(tidy$nfit[i+55]) & tidy$date[i] < cap){
        tidy$nfit[seq(i, by = 55, length.out = 12)] <- tidy$nfit[i]} 
    if (!is.na(tidy$vac[i]) & is.na(tidy$vac[i+55]) & tidy$date[i] < cap){
        tidy$vac[seq(i, by = 55, length.out = 12)] <- tidy$vac[i]} 
    if (!is.na(tidy$viol[i]) & is.na(tidy$viol[i+55]) & tidy$date[i] < cap){
        tidy$viol[seq(i, by = 55, length.out = 12)] <- tidy$viol[i]}}

rm(i, cap)

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
# PERCENTAGES FORMULA

tidy <- tidy %>%
    mutate(child_lead_aprc   = round(chlp, 3),
           crime_mprc        = round(crim / (tpop / 1000), 3) * 100,
           ela_fail_aprc     = round(fela, 3 ),
           larceny_mprc      = round(larc / (tpop / 1000), 3) * 100,
           lead_aprc         = round(lead / prop, 3) * 100,
           unfit_aprc        = round(nfit / prop, 3) * 100,
           wages_qprc        = round((11453 - qcew) / 12012, 3) * 100,
           ta_case_mprc      = round(tac / wpop, 3) * 100,
           ta_inds_mprc      = round(tai / wpop, 3) * 100,
           unemployment_mprc = round(uib / wpop, 3) * 100,
           vacancy_aprc      = round(vac / prop, 3) * 100,
           violation_aprc    = round(viol / prop, 3) * 100)

for( i in seq_along(tidy$wages_qprc)){
    if( !is.na(tidy$wages_qprc[i]) & tidy$wages_qprc[i] < 0 ){
        tidy$wages_qprc[i] <- 0}}; rm( i )

tidy <- tidy %>% rowwise() %>%
    mutate(index = round(sum(child_lead_aprc, crime_mprc, ela_fail_aprc,
                             larceny_mprc, lead_aprc, unfit_aprc, wages_qprc, 
                             ta_case_mprc, ta_inds_mprc, unemployment_mprc,
                             vacancy_aprc, violation_aprc,
                             na.rm = TRUE ), 3 ))

#--------------------------------------------------------------#
# WRITE TO .CSV

tidy$date <- as.character(tidy$date)

write_csv(tidy, "~/CNYCF/Poverty Index/Percentage Protoype/index_v2.csv")

tidy %>% select(date:prop, child_lead_aprc:index) %>%
    write_csv("~/CNYCF/Poverty Index/Percentage Protoype/index_v2_redact.csv")
