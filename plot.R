library(dplyr)
library(ggplot2)
library(targets)

tornados <- tar_read(tornados)

ky_tornados <- tornados |>
  filter(stf == 21)
  
# most of the data doesn't have an end lat lon
ky_tornados |>
  filter(elat != 0) |>
  ggplot() +
  geom_segment(
    aes(
      x = slon,
      y = slat,
      xend = elon,
      yend = elat
    )
  )
