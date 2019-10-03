# TA Data Cleaning Script

setwd("C:/Users/jamis/Downloads")

library(readr)
library(dplyr)
library(readxl)
library(stringr)

x <- read_excel("RidziTA_10_1_2019.xlsx", col_names = TRUE, col_type = c("text", "numeric", "numeric"))

# Read in Census Tracts

url <- "https://raw.githubusercontent.com/jamisoncrawford/Syracuse-Crime-Analysis/master/Data/fips_geoid.csv"

fips <- read_csv(url, col_types = "c")

# Tract Label Conversions

for (i in 1:length(x$CensusTract)){
  if (!str_detect(string = x$CensusTract[i], pattern = "\\.")){
    x$CensusTract[i] <- paste0(x$CensusTract[i], "00")
  }
}

for (i in 1:length(x$CensusTract)){
  if (str_detect(string = x$CensusTract[i], pattern = "\\.")){
    x$CensusTract[i] <- str_replace(string = x$CensusTract[i], pattern = "\\.", replacement = "")
  }
}

x$CensusTract <- str_pad(string = x$CensusTract, width = 6, side = "left", pad = "0")
x$CensusTract <- paste0("36067", x$CensusTract)

x <- x %>% rename(geoid = CensusTract)

# Filtering Join: 55 Tracts

x <- left_join(x = fips, y = x, by = "geoid")

x <- x %>% arrange(geoid)

x[is.na(x$CaseCount), c(2, 3)] <- 0

# Write to CSV

write_csv(x, "ta_2019_10_02.csv")
