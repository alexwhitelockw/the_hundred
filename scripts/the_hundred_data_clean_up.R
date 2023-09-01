# Clean-Up The Hundred Data

# Libraries ---------------------------

library(data.table)
library(jsonlite)
library(RSQLite)

# Own Functions -----------------------

source("functions/data_clean_up.R")

# Connect to Database -----------------

db_con <-
  dbConnect(SQLite(),
            "data/database/the_hundred_db.sqlite")

# JSON Files --------------------------

json_files <-
  list.files(
    "data/raw_data/",
    pattern = "json$",
    full.names = T,
    recursive = F
  )

# Match Information -------------------

match_information_df <-
  lapply(json_files,
         match_information)

match_information_df <-
  do.call(rbind,
          match_information_df)

dbWriteTable(
  conn = db_con,
  name = "match_information",
  value = match_information_df,
  overwrite = TRUE
)

# Match Player Information ------------

match_player_information_df <-
  lapply(json_files,
         match_player_information) |>
  rbindlist()

dbWriteTable(
  conn = db_con,
  name = "match_player_information",
  value = match_player_information_df,
  overwrite = TRUE
)

# Wicket and Run Information ----------

run_wicket_data <-
  lapply(json_files,
         innings_details)

# Run Data Extract and Database Import
run_data <- lapply(run_wicket_data, function(run_wicket_df) {
  lapply(run_wicket_df, function(match_df) {
    match_df$run
  }) |>
    rbindlist()
}) |>
  rbindlist()

dbWriteTable(
  conn = db_con,
  name = "match_run_information",
  value = run_data,
  overwrite = TRUE
)

# Wicket Data Extract and Database Import
wicket_data <- lapply(run_wicket_data, function(run_wicket_df) {
  lapply(run_wicket_df, function(match_df) {
    match_df$wicket
  }) |>
    rbindlist()
}) |>
  rbindlist()

dbWriteTable(
  conn = db_con,
  name = "match_wicket_information",
  value = wicket_data,
  overwrite = TRUE
)

# Disconnect from DB ------------------

dbDisconnect(db_con)
