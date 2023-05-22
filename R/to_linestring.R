to_linestring <- function(i) {
  st_linestring(matrix(as.numeric(ky_tornados[i, c("slon", "elon", "slat", "elat")]), nrow = 2))
}