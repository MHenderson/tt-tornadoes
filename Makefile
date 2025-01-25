all: png

png: plot/ky-tornadoes-plot.png

plot/ky-tornadoes-plot.png:
	Rscript -e "targets::tar_make()"
