library(ggplot2)
library(targets)

ky_counties <- tar_read(ky_counties)
ky_tornadoes <- tar_read(ky_tornadoes)
ky_towns <- tar_read(ky_towns)

ggplot() +
  geom_sf(data = ky_counties, fill = "white", color = "black", linewidth = 0.1) +
  geom_sf(data = ky_tornadoes, aes(colour = as.factor(mag)),
          arrow = arrow(angle = 45, ends = "last", type = "open", length = unit(0.05, "inches"))) +
  #geom_sf(data = ky_towns) +
  #geom_sf_text(data = ky_towns, aes(label = FULLNAME), nudge_x = -.2, nudge_y = -.2) +
  theme_void()
