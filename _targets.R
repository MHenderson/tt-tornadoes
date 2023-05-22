# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("dplyr", "ggplot2", "janitor", "readr", "sf", "tibble", "tigris"), # packages that your targets need to run
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

      ky_tornadoes <- tornados |>
        filter(stf == 21) |>
        filter(elat != 0)

      to_linestring <- function(i) {
        st_linestring(matrix(as.numeric(ky_tornadoes[i, c("slon", "elon", "slat", "elat")]), nrow = 2))
      }

      ky_tornadoes$geom <- sapply(1:nrow(ky_tornadoes), to_linestring, simplify = FALSE)
      st_sf(ky_tornadoes, crs = 4326)

    }
  ),
  tar_target(
    name = ky_tornadoes_plot,
    command = {
      ggplot() +
        geom_sf(data = ky_counties, fill = "white", color = "black") +
        geom_sf(data = ky_tornadoes, aes(colour = as.factor(mag))) +
        geom_sf(data = ky_towns) +
        geom_sf_text(data = ky_towns, aes(label = FULLNAME), nudge_x = -.2, nudge_y = -.2) +
        theme_void()
    }
  ),
  tar_target(
    name = save_plot,
    command = ggsave(plot = ky_tornadoes_plot, filename = "plot/ky-tornadoes-plot.png", bg = "white", width = 10, height = 8),
    format = "file"
  )
)
