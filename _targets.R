# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("dplyr", "janitor", "readr", "sf", "tibble", "tigris"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
list(
  tar_target(
    name = tornados,
    command = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-05-16/tornados.csv')
  ),
  tar_target(
    name = ky_counties,
    command = counties(state = "KY") |> clean_names()
  ),
  tar_target(
    name = ky_landmarks,
    command = landmarks("KY")
  ),
  tar_target(
    name = ky_towns,
    command = {

      ky_landmarks |>
        filter(FULLNAME %in% c("Berea", "Bowling Green")) |>
        st_transform(crs = 4326)
    
    }
  ),
  tar_target(
    name = ky_tornadoes,
    command = {

      ky_tornados <- tornados |>
        filter(stf == 21) |>
        filter(elat != 0) |>
        filter(date >= "2007-07-01") |>
        filter(date <= "2010-08-28")

      ky_tornados$geom <- sapply(1:nrow(ky_tornados), to_linestring, simplify = FALSE)
      st_sf(ky_tornados, crs = 4326)

    }
  )
)
