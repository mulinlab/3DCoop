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

n <- 8

for (cell in cells) {
  set.seed(1000)

  df_nodes <- read_tsv(file.path(dinout, paste0(cell, "_nodes.txt")))
  df_links <- read_tsv(file.path(dinout, paste0(cell, "_links.txt")))
  df_nodes <- df_nodes %>% mutate(id=as.factor(cid%%n))
  
  dg <- graph_from_data_frame(df_links, directed=FALSE, vertices=df_nodes)
  l <- layout_with_fr(dg)
  
  g <- ggnetwork(dg, layout=l)
  gg <- ggplot(data=g, aes(x=x, y=y, xend=xend, yend=yend))
  gg <- gg + geom_edges(size=df_links$weight * 2, color="gray80")
  gg <- gg + geom_nodes(aes(shape=as.factor(share), color=as.factor(id)), size=8)
  gg <- gg + theme_blank(legend.position="none")
  gg <- gg + geom_nodetext_repel(aes(label=vertex.names), point.padding=unit(0.3, "lines"), family="serif")
  fop <- file.path(dinout, paste0(cell,"_network.png"))
  ggsave(fop, gg, width=20, height=20)
  fof <- file.path(dinout, paste0(cell, "_network.pdf"))
  ggsave(fof, gg, width=20, height=20)
}
