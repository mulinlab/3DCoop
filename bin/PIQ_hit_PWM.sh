#!/bin/bash

path_to_piq=$1
file_motif=$2
dir_out=$3

mkdir -p $dir_out

num=$(grep ">" $file_motif | wc -l)

for idx in $(seq 1 $num)
do
  Rscript $path_to_piq/pwmmatch.exact.r $path_to_piq/common.r $file_motif $idx $dir_out
done
