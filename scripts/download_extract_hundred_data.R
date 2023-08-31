# Download and Extract The Hundred Data

# Download and Extract Files ----------

download.file("https://cricsheet.org/downloads/hnd_json.zip",
              destfile = "data/raw_data/the_hundred_json.zip",
              cacheOK = T)

unzip("data/raw_data/the_hundred_json.zip",
      exdir = "data/raw_data/")