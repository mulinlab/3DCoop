#library(igraph)
suppressMessages(library(igraph))

args <- commandArgs(trailingOnly = TRUE)
fi <- args[1]
minn <- args[2]
maxn <- args[3]
fo <- args[4]

df <- read.table(fi, header = FALSE)
g <- graph.data.frame(df, directed = FALSE)

cl <- vector()
for (i in minn:maxn) {
  x <- cliques(g, min = i, max = i)
  cl <- c(cl, x)
}

for (i in 1:length(cl)) {
  sink(fo, append = TRUE)
  cat(names(cl[[i]]), sep = "\t")
  cat("\n")
  sink()
}
