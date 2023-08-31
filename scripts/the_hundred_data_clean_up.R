# Clean-Up The Hundred Data

# Libraries ---------------------------

library(jsonlite)
library(RSQLite)
library(stringi)

# Own Functions -----------------------

source("functions/data_clean_up.R")

# Connect to Database -----------------

db_con <- 
  dbConnect(
    SQLite(),
    "data/database/the_hundred_db.sqlite"
  )

# JSON Files --------------------------

json_files <-
  list.files(
    "data/raw_data/", 
    pattern = "json$", 
    full.names = T, 
    recursive = F)

# Match Information -------------------

match_information <- 
  lapply(
    json_files, 
    match_information)

match_information <-
  do.call(
    rbind, 
    match_information)

dbWriteTable(
  conn = db_con,
  name = "match_information",
  value = match_information
)

