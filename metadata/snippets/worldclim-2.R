# WorldClim 2.1 monthly climate normals (1970-2000) with the geodata package
library(geodata)
prec <- worldclim_global(var = "prec", res = 10, path = tempdir())  # res in arc-minutes: 10, 5, 2.5 or 0.5
