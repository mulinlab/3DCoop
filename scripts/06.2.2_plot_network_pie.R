#!/usr/bin/Rscript

library(tidyverse)
library(DescTools)
library(igraph)
library(ggnetwork)
library(intergraph)


args <- commandArgs(trailingOnly=TRUE)
fi_cfg <- args[1]
df_cfg <- read_tsv(fi_cfg)

dio <- df_cfg %>% filter(key=="dir_out") %>% pull(value)
str_cells <- df_cfg %>% filter(key=="cells") %>% pull(value)
cells <- sort(unique(str_split(str_cells, ",", simplify=TRUE)[1,]))

dinout <- file.path(dio, "06_network")


mix_color <- function (str_color) {
  colors <- strsplit(str_color, ",")[[1]]

  if(length(colors)==1){
    return(c(colors))
  }
  
  if(length(colors)>=2){
    mix <- colors[1]
    for (i in 1:(length(colors)-1)){
      mix <- MixColor(mix, colors[i+1], amount1=i/(i+1))
    }
    return(c(mix))
  }
}

# Transcription factor, Transcription cofactor, Others, RNA binding protein, Chromatin remodeller, Nuclear enzyme, Polycomb group (PcG) protein
# color_class <- c("#E41A1C", "#377EB8", "#999999", "#4DAF4A", "#A65628", "#FF7F00", "#984EA3")
color_class <- c("#D95757", "#3366CC", "#DD4477", "#109618", "#FF9900", "#0099C6", "#990099")

for (cell in cells) {
  set.seed(1000)
  df_nodes <- read_tsv(file.path(dinout, paste0(cell, "_nodes4pie.txt")))
  df_links <- read_tsv(file.path(dinout, paste0(cell, "_links4pie.txt")))
  
  dg <- graph_from_data_frame(df_links, directed=FALSE, vertices=df_nodes)
  # tkplot(dg)
  # pie_values <- lapply(strsplit(df_nodes$code, ""), as.numeric) # for code
  pie_values <- lapply(strsplit(df_nodes$value, ","), as.numeric)
  pie_color <- strsplit(df_nodes$color, ",")
  alpha_color <- lapply(pie_color, SetAlpha, alpha=0.5)
  df_nodes <- df_nodes %>% group_by(tf) %>% mutate(mix=mix_color(as.character(color)))
  
  # V(dg)$size <- sqrt((df_nodes$hub + 1) * 9) + 0.5
  V(dg)$size <- sqrt((df_nodes$hub + 1) * 2) + 0.5
  # V(dg)$size <- sqrt(df_nodes$degree) * 2 # for node degree
  # V(dg)$size <- df_nodes$degree + 2 # for link weight
  E(dg)$edge.color <- "gray80"
  l <- layout_with_fr(dg)
  
  E(dg)$width <- df_links$weight * 2
  png(file.path(dinout, paste0(cell, "_network_pie.png")), width=4200, height=4200, res=300)
  plot(dg, 
       vertex.shape="pie", vertex.pie=pie_values, vertex.pie.color=pie_color, vertex.pie.lty=0,
       vertex.label=NA,
       layout=l)
  dev.off()
  png(file.path(dinout, paste0(cell, "_network_pie_label.png")), width=4200, height=4200, res=300)
  plot(dg, 
       vertex.shape="pie", vertex.pie=pie_values, vertex.pie.color=alpha_color, vertex.pie.lty=0,
       vertex.label.color="black", vertex.label.cex=0.5, vertex.label.dist=0, vertex.label.family="Helvetica", vertex.label.font=2,
       layout=l)
  dev.off()
  
  E(dg)$width <- df_links$weight * 5
  pdf(file.path(dinout, paste0(cell, "_network_pie.pdf")), width=14, height=14)
  # pdf(file.path(dinout, paste0(cell, "_network_pie.pdf")), width=25, height=25)
  plot(dg, 
       vertex.shape="pie", vertex.pie=pie_values, vertex.pie.color=pie_color, vertex.pie.lty=0, 
       vertex.label=NA,
       layout=l)
  dev.off()
  pdf(file.path(dinout, paste0(cell, "_network_pie_label.pdf")), width=14, height=14)
  plot(dg, 
       vertex.shape="pie", vertex.pie=pie_values, vertex.pie.color=alpha_color, vertex.pie.lty=0, 
       vertex.label.color="black", vertex.label.cex=0.5, vertex.label.dist=0, vertex.label.family="Helvetica", vertex.label.font=2,
       layout=l)
  dev.off()
  
  
  g <- ggnetwork(dg, layout=l)
  gg <- ggplot(data=g, aes(x=x, y=y, xend=xend, yend=yend))
  gg <- gg + geom_edges(size=df_links$weight * 2, color="gray80")
  gg <- gg + geom_nodes(color=df_nodes$mix, size=sqrt((df_nodes$hub + 1) * 9) + 0.5)
  gg <- gg + theme_blank(legend.position="none")
  gg <- gg + geom_nodetext_repel(aes(label=name), point.padding=unit(0.3, "lines"), family="Arial")
  fop <- file.path(dinout, paste0(cell,"_network.png"))
  ggsave(fop, gg, width=20, height=20)
  fof <- file.path(dinout, paste0(cell, "_network.pdf"))
  ggsave(fof, gg, width=20, height=20, device=cairo_pdf)
}
