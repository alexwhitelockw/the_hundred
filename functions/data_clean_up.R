# The Hundred Clean-Up Functions

# Libraries ---------------------------

library(data.table)
library(jsonlite)
library(stringi)

# Unique Match Number -----------------
# Used for the purpose of joining tables together -- each
# match has a unique number attached.

unique_match_number <- function(json_file) {
  record_number <-
    stri_extract(basename(json_file),
                 regex = "[0-9]{7}")
}

# Match Information -------------------
# Clean-up match information such as the teams playing,
# the match venue, and match winner.

match_information <- function(json_file) {
  
  unique_match_number <-
    unique_match_number(json_file)
  
  json_read <-
    read_json(json_file)
  
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
        json_read$info$outcome$winner
      ),
      player_of_match = ifelse(
        is.null(json_read$info$player_of_match[[1]]),
        NA,
        json_read$info$player_of_match[[1]]
      )
    )
  
  return(match_information_df)
  
}

# Player Match Information ------------
# Clean-up team player information such as the team name,
# player number, and player name.

match_player_information <- function(json_file) {
  
  unique_match_number <-
    unique_match_number(json_file)
  
  json_read <-
    read_json(json_file)
  
  team_one <-
    rbindlist(json_read$info$players[1],
              idcol = "team_name") |>
    melt(id.vars = "team_name",
         variable.name = "player_number",
         value.name = "player_name")
  
  team_two <-
    rbindlist(json_read$info$players[2],
              idcol = "team_name") |>
    melt(id.vars = "team_name",
         variable.name = "player_number",
         value.name = "player_name")
  
  team_players <-
    rbind(team_one,
          team_two)
  
  team_players[,
               player_number := gsub(pattern = "V",
                                     replacement = "",
                                     player_number)]
  
  team_players[,
               match_number := unique_match_number
               ]
  
  return(team_players)
  
}

# Run and Wicket Information
# Extract information on the runs per over and the 
# wickets per over

extract_run_information <- function(over_list) {
  over_number <-
    over_list$over
  
  over_deliveries <-
    over_list$deliveries
  
  run_information <- lapply(over_deliveries, function(df) {
    run_df <- data.frame(
      over_number = over_number,
      batter_name = df$batter,
      bowler_name = df$bowler,
      non_striker_name = df$non_striker,
      batter_runs = df$runs$batter,
      extra_runs = df$runs$extras,
      total_runs = df$runs$total
    )
  }) |>
    rbindlist()
  
}

extract_wicket_information <- function(over_list) {
  over_number <-
    over_list$over
  
  over_deliveries <-
    over_list$deliveries
  
  wicket_information <- lapply(over_deliveries, function (df) {
    if (exists("wickets", df)) {
      wicket_player_out <-
        df$wickets[[1]]$player_out
      wicket_kind <-
        df$wickets[[1]]$kind
      wicket_df <-
        data.frame(
          over_number = over_number,
          wicket_player_out = wicket_player_out,
          wicket_kind = wicket_kind
        )
      return(wicket_df)
    }
    else {
      wicket_df <-
        data.frame(
          over_number = over_number,
          wicket_player_out = NA,
          wicket_kind = NA
        )
      return(wicket_df)
    }
  }) |>
    rbindlist()
}

innings_details <- function(json_file) {
  
  json_read <- 
    read_json(json_file)
  
  unique_match_number <-
    unique_match_number(json_file)
  
  innings_list <-
    json_read$innings  # Innings information
  
  lapply(innings_list, function(df) {
    
    # Cricket Team Name
    team_name <-
      df$team
    
    # List of Over Details
    over_details <-
      df$overs
    
    # Extract Wicket Details
    wicket_information <-
      lapply(over_details, extract_wicket_information) |>
      rbindlist()
    wicket_information[, team_name := team_name]
    wicket_information[, match_number := unique_match_number]
    
    # Extract Run Details
    run_information <-
      lapply(over_details, extract_run_information) |>
      rbindlist()
    run_information[, team_name := team_name]
    run_information[, match_number := unique_match_number]
    
    run_wicket_information <-
      list(
        wicket = wicket_information,
        run = run_information
      )
    
    return(run_wicket_information)
    
  })
}