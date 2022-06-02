
awesome_geodata_table <- read_delim("inst/extdata/awesome_geodata_table.csv",
delim = ";", escape_double = FALSE, trim_ws = TRUE)

awesome_geodata_table[nrow(awesome_geodata_table)+1,] <- NA
awesome_geodata_table$Name[nrow(awesome_geodata_table)] <- c("Global pesticide pollution risk")
awesome_geodata_table$Tags[nrow(awesome_geodata_table)] <- paste("pesticides", "pollution", "risk", "health")
awesome_geodata_table$Domain[nrow(awesome_geodata_table)] <- c("agriculture")
awesome_geodata_table$Resolution...4[nrow(awesome_geodata_table)] <- c("1 a")
awesome_geodata_table$Resolution...5[nrow(awesome_geodata_table)] <- c("1 a")
awesome_geodata_table$Resolution...6[nrow(awesome_geodata_table)] <- c("5 arc-min (10km at the equator)")
awesome_geodata_table$Resolution...7[nrow(awesome_geodata_table)] <- c("5 arc-min (10km at the equator)")
awesome_geodata_table$Extent...8[nrow(awesome_geodata_table)] <- NA
awesome_geodata_table$Extent...9[nrow(awesome_geodata_table)] <- NA
awesome_geodata_table$Extent...10[nrow(awesome_geodata_table)] <- "global"
awesome_geodata_table$Data...11[nrow(awesome_geodata_table)] <- "raster"
awesome_geodata_table$Data...12[nrow(awesome_geodata_table)] <- "GeoTiff"
awesome_geodata_table$Data...13[nrow(awesome_geodata_table)] <- ".tif"
awesome_geodata_table$Data...14[nrow(awesome_geodata_table)] <- "https://figshare.com/articles/dataset/Global_pesticide_pollution_risk_data_sets/10302218"
awesome_geodata_table$'Publication Year'[nrow(awesome_geodata_table)] <- 2022
awesome_geodata_table$'Publication link'[nrow(awesome_geodata_table)] <- "https://www.nature.com/articles/s41561-021-00712-5"
awesome_geodata_table$'Version updates'[nrow(awesome_geodata_table)] <- "no"
awesome_geodata_table$'Upload frequency'[nrow(awesome_geodata_table)] <- NA
awesome_geodata_table$'Temporal type'[nrow(awesome_geodata_table)] <- "static"
awesome_geodata_table$Access[nrow(awesome_geodata_table)] <- "free"
awesome_geodata_table$Publisher[nrow(awesome_geodata_table)] <- "nature"
awesome_geodata_table$'Data limitations'[nrow(awesome_geodata_table)] <- "NA"
awesome_geodata_table$Method[nrow(awesome_geodata_table)] <- "hybrid"
awesome_geodata_table$'Usage requirement'[nrow(awesome_geodata_table)] <- "final product"
awesome_geodata_table$Comment[nrow(awesome_geodata_table)] <- "This data set is licenced by CC BY 4.0. Datacanbe freely downloaded for research, study, or teaching, but must be cited appropriately."

 write.csv(awesome_geodata_table, file="awesome_geodata_table.csv", row.names = F)
