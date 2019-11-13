#!/usr/bin/Rscript

library(tidyverse)
library(reshape)
library(huge)


df2mat <- function(df){
  df <- as.data.frame(df)
  colnames(df) <- c("x", "y", "z")
  ids <- sort(unique(c(as.character(df$x), as.character(df$y))))
  mat <- matrix(NA, nrow=length(ids), ncol=length(ids), dimnames=list(ids, ids))
  diag(mat) <- 1
  #fill
  mat[as.matrix(df[, 1:2])] <- df[,3]
  #fill reversed
  mat[as.matrix(df[, 2:1])] <- df[,3]
  return(mat)
}

mat2df <- function(mat){
  df <- melt(mat)[melt(upper.tri(mat))$value,]
  names(df) <- c("TF1", "TF2", "value")
  df$TF1 <- as.character(df$TF1)
  df$TF2 <- as.character(df$TF2)
  return(df)
}

scale_matrix <- function(mat) {
  dm <- dim(mat)
  rn <- rownames(mat)
  mat2 <- scale(c(mat))
  dim(mat2) <- dm
  rownames(mat2) <- rn
  return(mat2)
}

args <- commandArgs(trailingOnly=TRUE)
fi_cfg <- args[1]
df_cfg <- read_tsv(fi_cfg)

dio <- df_cfg %>% filter(key=="dir_out") %>% pull(value)
str_cells <- df_cfg %>% filter(key=="cells") %>% pull(value)
cells <- sort(unique(str_split(str_cells, ",", simplify=TRUE)[1,]))

din <- file.path(dio, "03_jaccard")
dout <- file.path(dio, "04_glasso")
dir.create(dout, showWarnings=FALSE)

for (cell in cells){
  fin <- file.path(din, paste0("jaccard_", cell, ".txt"))
  fout <- file.path(dout, paste0("glasso_", cell, ".txt"))
  
  jac <- read_tsv(fin)
  jac <- jac %>% dplyr::select(TF1, TF2, Jaccard)
  
  mat <- df2mat(jac)
  #X.npn <- scale_matrix(mat)
  X.npn <- huge.npn(mat)
  #out.npn <- huge(X.npn, lambda=0.127, method="glasso")
  out.npn <- huge(X.npn, method="glasso")
  #plot.huge(out.npn)
  npn.ebic <- huge.select(out.npn, criterion="ebic")
  #plot.select(npn.ebic)
  
  gm <- as.matrix(npn.ebic$opt.icov)
  rn <- rownames(mat)
  cn <- colnames(mat)
  rownames(gm) <- rn
  colnames(gm) <- cn
  df <- mat2df(gm)
  df <- df %>% filter(value<0) %>% mutate(weight=abs(value)) %>% dplyr::select("#TF1"=TF1, TF2, weight)
  write_tsv(df, fout)
}
