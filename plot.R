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

decade_labels <- paste0(seq(1950, 2020, 10), "s")
decade_labels[1] <- "1952 - 1959"
decade_labels[8] <- "2020 - 2022"
names(decade_labels) <- seq(1950, 2020, 10)

ggplot() +
  geom_sf(data = kentucky, colour = "black") +
  geom_sf(data = ky_tornadoes,
          aes(colour = as.factor(mag)),
          linewidth = 1,
          arrow = arrow(angle = 45, ends = "last", type = "open", length = unit(0.05, "inches"))) +
  #theme_void() +
  theme_ipsum_rc() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
         axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
         axis.text.y = element_blank(),
        axis.ticks.y = element_blank()
  ) +
  scale_color_brewer(palette = "Reds") +
  #facet_wrap(~ decade) +
  theme(legend.position = "bottom") +
  guides(colour = guide_legend(nrow = 1, byrow = TRUE)) +
  labs(
    colour = "Tornado Intensity\n(F-Scale before 2007, EF-Scale after 2007)"
  ) +
  facet_wrap(~decade, labeller = labeller(decade = decade_labels)) +
  labs(
    title = "Tornado Paths in Kentucky",
    subtitle = "1952 - 2022",
    caption = "Data: NOAA's National Weather Service Storm Prediction Center\nGraphics: Matthew Henderson"
  )
