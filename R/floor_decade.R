# https://stackoverflow.com/questions/35352914/floor-a-year-to-the-decade-in-r
floor_decade <- function(value){ return(value - value %% 10) }