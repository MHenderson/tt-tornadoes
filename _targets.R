# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("dplyr", "ggplot2", "hrbrthemes", "janitor", "readr", "sf", "tibble", "tigris"), # packages that your targets need to run
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
    name = kentucky,
    command = {
      us_states <- states(class = "sf")
      us_states[us_states$STUSPS == "KY", ]
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

      decade_labels <- paste0(seq(1950, 2020, 10), "s")
      decade_labels[1] <- "1952 - 1959"
      decade_labels[8] <- "2020 - 2022"
      names(decade_labels) <- seq(1950, 2020, 10)
      
      ggplot() +
        geom_sf(data = kentucky, colour = "black") +
        geom_sf(data = ky_tornadoes |> filter(!is.na(mag)) |> mutate(decade = floor_decade(yr)),
                aes(colour = as.factor(mag)),
                linewidth = 1,
                arrow = arrow(angle = 45, ends = "last", type = "open", length = unit(0.05, "inches"))) +
        facet_wrap(~decade, labeller = labeller(decade = decade_labels)) +
        scale_color_brewer(palette = "Reds") +
        guides(colour = guide_legend(nrow = 1, byrow = TRUE)) +
        theme_ipsum_rc() +
        theme(
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
               axis.text.x = element_blank(),
              axis.ticks.x = element_blank(),
               axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
           legend.position = "bottom"
        ) +
        labs(
          title = "Tornado Paths in Kentucky",
          subtitle = "1952 - 2022",
          caption = "Data: NOAA's National Weather Service Storm Prediction Center\nGraphics: Matthew Henderson",
          colour = "Tornado Intensity\n(F-Scale before 2007, EF-Scale after 2007)"
        )
    }
  ),
  tar_target(
    name = save_plot,
    command = ggsave(plot = ky_tornadoes_plot, filename = "plot/ky-tornadoes-plot.png", bg = "white", width = 10, height = 8),
    format = "file"
  )
)
