#!/usr/bin/Rscript

library(tidyverse)

args <- commandArgs(trailingOnly=TRUE)
fi_cfg <- args[1]
df_cfg <- read_tsv(fi_cfg)

dio <- df_cfg %>% filter(key=="dir_out") %>% pull(value)
str_cells <- df_cfg %>% filter(key=="cells") %>% pull(value)
cells <- sort(unique(str_split(str_cells, ",", simplify=TRUE)[1,]))

dio_number <- file.path(dio, "05_clusterone/02_number")

for (cl in cells){
  fi <- file.path(dio_number, paste0(cl, "_clique_number.txt"))
  
  df <- read_tsv(fi)

  dfd <- df %>% group_by(density) %>% summarise(number=sum(number))
  pd <- ggplot(dfd, aes(x=density, y=number)) + geom_point() + geom_line()
  #pd
  ggsave(file.path(dio_number, paste0(cl, "_all_density.png")), pd)

  dfc <- df %>% filter(k<=7) %>% mutate(k=as.character(k))
  dfa <- dfc %>% group_by(cell, density) %>% summarise(number=sum(number)) %>% mutate(k="34567") %>% select(cell, k, density, number)
  dff <- bind_rows(dfc, dfa)
  pf <- ggplot(dff, aes(x=density, y=number)) + geom_point() + geom_line() + facet_grid(k ~ .)
  ggsave(file.path(dio_number, paste0(cl, "_k_density.png")), pf)
}
