# TA Conversion Script
  ## R Version: 3.5.1
  ## RStudio Version: 1.1.456

library(readr)
library(dplyr)
library(readxl)
library(stringr)
library(lubridate)

rm(list = ls())
setwd("~/CNYCF/CNY Data Updates/DSS TA/New TA Data")
newta <- read_excel("RidziTA_1_2_19.xlsx",              # Set new file name here
                    col_types = ("text"))

geoid <- data_frame("geoid" = c("36067000100", "36067000200", "36067000300", "36067000400", "36067000501", 
                                "36067000600", "36067000700", "36067000800", "36067000900", "36067001000", 
                                "36067001400", "36067001500", "36067001600", "36067001701", "36067001702", 
                                "36067001800", "36067001900", "36067002000", "36067002101", "36067002300", 
                                "36067002400", "36067002700", "36067002901", "36067003000", "36067003200", 
                                "36067003400", "36067003500", "36067003601", "36067003602", "36067003800", 
                                "36067003900", "36067004000", "36067004200", "36067004301", "36067004302", 
                                "36067004400", "36067004500", "36067004600", "36067004800", "36067004900", 
                                "36067005000", "36067005100", "36067005200", "36067005300", "36067005400", 
                                "36067005500", "36067005601", "36067005602", "36067005700", "36067005800", 
                                "36067005900", "36067006000", "36067006101", "36067006102", "36067006103"))

newta <- newta %>%
  rename("geoid" = CensusTract,
         "case" = CaseCount,
         "individual" = IndividualCount) %>%
  mutate(date = date("2019-01-01"))              # Set new date here

# index <- which(str_detect(string = newta$geoid, pattern = "NULL"))     # Remove particular values
# newta <- newta[-index, ]

for (i in 1:nrow(newta)){
  if (!str_detect(string = newta$geoid[i], pattern = "\\.")){
    newta$geoid[i] <- paste(newta$geoid[i], "00", sep = "")
  } else if (str_detect(string = newta$geoid[i], pattern = "\\.")){
    newta$geoid[i] <- str_replace(string = newta$geoid[i], pattern = "\\.", replacement = "")
  }
}

newta$geoid <- str_pad(string = newta$geoid, width = 6, side = "left", pad = "0")

for (i in 1:nrow(newta)){
  newta$geoid[i] <- paste("36067", newta$geoid[i], sep = "")
}

output <- left_join(geoid, newta, by = "geoid") %>%
  select(date, geoid, case:individual)

write_csv(output, "ta_2019-01-04.csv")     # Rename output file here
