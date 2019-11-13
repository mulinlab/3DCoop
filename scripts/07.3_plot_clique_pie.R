#!/usr/bin/Rscript

library(tidyverse)
library(igraph)


set.seed(1000)

args <- commandArgs(trailingOnly=TRUE)
dir_work <- args[1]
cell <- args[2]
dio <- file.path(dir_work, "07_cliques", cell)

# Transcription factor, Transcription cofactor, Others, RNA binding protein, Chromatin remodeller, Nuclear enzyme, Polycomb group (PcG) protein
#color_class <- c("#E41A1C", "#377EB8", "#999999", "#4DAF4A", "#A65628", "#FF7F00", "#984EA3")
color_class <- c("#D95757", "#3366CC", "#DD4477", "#109618", "#FF9900", "#0099C6", "#990099")

fils <- list.files(dio, "*.links")

for (fil in fils){
  name <- str_replace(fil, "\\.links", "")
  
  fi_link <- file.path(dio, fil)
  fi_node <- file.path(dio, str_replace(fil, "links", "nodes"))
  
  df_nodes <- read_tsv(fi_node)
  df_links <- read_tsv(fi_link)
  
  dg <- graph_from_data_frame(df_links, directed=FALSE, vertices=df_nodes)
  
  pie_values <- lapply(strsplit(as.character(df_nodes$value), ","), as.numeric)
  pie_color <- strsplit(df_nodes$color, ",")
  
  V(dg)$size <- (df_nodes$hub + 1) * 25
  E(dg)$edge.color <- "gray80"
  
  set.seed(999)
  l <- layout_with_fr(dg)
  
  E(dg)$width <- df_links$weight * 8
  png(file.path(dio, paste0(name, ".png")), width=3000, height=3000, res=600)
  plot(dg, 
       vertex.shape="pie", vertex.pie=pie_values, vertex.pie.color=pie_color, vertex.pie.lty=0,
       #vertex.label=NA,
       vertex.label.color="black", vertex.label.cex=0.8, vertex.label.dist=3.5, vertex.label.family="Times", vertex.label.font=2,
       layout=l)
  dev.off()
  
  E(dg)$width <- df_links$weight * 100
  pdf(file.path(dio, paste0(name, ".pdf")), width=30, height=25, family="Times")
  plot(dg, 
       vertex.shape="pie", vertex.pie=pie_values, vertex.pie.color=pie_color, vertex.pie.lty=0, 
       #vertex.label=NA,
       vertex.label.color="black", vertex.label.cex=12, vertex.label.dist=6, vertex.label.family="Times", vertex.label.font=2,
       layout=l)
  dev.off()
}
