setwd("YOUR WORKING DIRECTORY HERE")

DATA_DIR = "data"
YEAR_DIR = "2019"
URL = "https://api.cartolafc.globo.com/atletas/mercado"

library(jsonlite)
library(dplyr)
library(stringr)
library(xlsx)



# Creating the data directory:
if(!dir.exists(DATA_DIR)) dir.create(DATA_DIR, showWarnings = F)
if(!dir.exists(file.path(DATA_DIR, YEAR_DIR))) dir.create(file.path(DATA_DIR, YEAR_DIR), showWarnings = F)



# Getting the market data:
lst_market <- fromJSON(URL)


## Athletes data:
df_athl <- data.frame(lst_market$atletas)

### Removing unused variables:
df_athl <- df_athl[1:14]
df_athl$foto = NULL
df_athl$slug = NULL

### Merging the scouts:
df_athl <- cbind(df_athl, lst_market$atletas$scout)


## Clubs data:
df_club <- data.frame(matrix(unlist(lst_market$clubes), ncol = 8, byrow = T))

### Removing unused variables
df_club <- df_club[,1:4]

### Changing the variable names:
names(df_club) <- c("clube_id", "clube_nome", "clube_abrev", "clube_classif")


## Positions data:
df_pos <- data.frame(matrix(unlist(lst_market$posicoes), ncol = 3, byrow = T))

### Changing the variable names:
names(df_pos) <- c("posicao_id", "posicao_nome", "posicao_abrev")


## Athlete status data:
df_stat <- data.frame(matrix(unlist(lst_market$status), ncol = 2, byrow = T))

### Changing the variable names:
names(df_stat) <- c("status_id", "status_nome")



# Consolidating the data:
df <- merge(df_athl, df_club, by = "clube_id")
df <- merge(df, df_pos, by = "posicao_id")
df <- merge(df, df_stat, by = "status_id")

## Replacing all missing values for zero:
df <- df %>% mutate_if(is.integer, ~replace(., is.na(.), 0))



# Saving the data:
filename <- paste("rodada", str_pad(string = df$rodada_id[1], width = 2, side = "left", pad = 0), sep="-")

## csv format:
filename.csv <- paste0(filename, ".csv")
write.csv(df, file.path(DATA_DIR, YEAR_DIR, filename.csv))

## xlsx format:
filename.xlsx <- paste0(filename, ".xlsx")
write.xlsx(df, file.path(DATA_DIR, YEAR_DIR, filename.xlsx))












