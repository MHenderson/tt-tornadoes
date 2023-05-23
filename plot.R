library(dplyr)
library(ggplot2)
library(targets)

ky_counties <- tar_read(ky_counties)
ky_tornadoes <- tar_read(ky_tornadoes)
ky_towns <- tar_read(ky_towns)

us_states <- tigris::states(class = "sf")
kentucky <- us_states[us_states$STUSPS == "KY", ]

# https://stackoverflow.com/questions/35352914/floor-a-year-to-the-decade-in-r
floor_decade <- function(value){ return(value - value %% 10) }
ky_tornadoes <- ky_tornadoes |>
  filter(!is.na(mag)) |>
  mutate(decade = floor_decade(yr))

ggplot() +
  geom_sf(data = kentucky, colour = "black") +
  geom_sf(data = ky_counties, fill = "lightgrey", color = "black", linewidth = 0.1) +
  geom_sf(data = ky_tornadoes,
          aes(colour = as.factor(mag)),
          linewidth = 1,
          arrow = arrow(angle = 45, ends = "last", type = "open", length = unit(0.05, "inches"))) +
  theme_void() +
  scale_color_brewer(palette = "Reds") +
  #facet_wrap(~ decade) +
  theme(legend.position = "bottom") +
  guides(colour = guide_legend(nrow = 1, byrow = TRUE)) +
  labs(
    colour = "Intensity (EF-Scale)"
  )
