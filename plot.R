library(dplyr)
library(ggplot2)
library(targets)
library(tigris)
library(janitor)

tornados <- tar_read(tornados)

ky_tornados <- tornados |>
  filter(stf == 21)
  
# most of the data doesn't have an end lat lon
ky_tornados_td <- ky_tornados |> filter(elat != 0)

kentucky_counties <- counties(state = "KY") %>%
  clean_names()

ky_landmarks <- landmarks("KY")
ky_towns_to_plot <- c("Berea", "Bowling Green", "Lexington", "Louisville")
ky_towns <- ky_landmarks %>% filter(FULLNAME %in% ky_towns_to_plot)

kentucky_counties |>
  ggplot() +
    geom_sf(fill = "white", color = "black") +
    geom_segment(
      data = ky_tornados_td,
      arrow = arrow(length = unit(0.015, "npc")),
      aes(
        x = slon,
        y = slat,
        xend = elon,
        yend = elat,
        colour = as.factor(mag)
      )
    ) +
    theme_void()


