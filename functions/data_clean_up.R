# The Hundred Clean-Up Functions

# Libraries ---------------------------

library(stringi)

# Unique Match Number -----------------
# Used for the purpose of joining tables together -- each
# match has a unique number attached.

unique_match_number <- function(json_file) {
  record_number <- 
    stri_extract(
      basename(json_file),
      regex = "[0-9]{7}")
}

# Match Information -------------------
# Clean-up match information such as the teams playing,
# the match venue, and match winner.

match_information <- function(json_file) {
  unique_match_number <-
    unique_match_number(json_file)
  json_read <- 
    read_json(
      json_file)
  match_information_df <-
    data.frame(
      match_number = unique_match_number,
      venue = json_read$info$venue,
      venue_city = json_read$info$city,
      season = json_read$info$season,
      match_date = json_read$info$dates[[1]],
      team_one = json_read$info$teams[[1]],
      team_two = json_read$info$teams[[2]],
      toss_winner = json_read$info$toss$winner,
      toss_decision = json_read$info$toss$decision,
      match_winner = ifelse(
        is.null(json_read$info$outcome$winner),
        NA,
        json_read$info$outcome$winner),
      player_of_match = ifelse(
        is.null(json_read$info$player_of_match[[1]]),
        NA,
        json_read$info$player_of_match[[1]])
    )
  return(match_information_df)
}
