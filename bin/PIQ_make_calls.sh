#!/bin/bash

path_to_piq=$1
file_motif=$2
path_to_pwm=$3
file_bam_rdata=$4
dir_out=$5

dir_out_tmp="$dir_out/tmp"
mkdir -p $dir_out_tmp
dir_out_call="$dir_out/call"
mkdir -p $dir_out_call

num=$(grep ">" $file_motif | wc -l)

for idx in $(seq 1 $num)
do
  Rscript $path_to_piq/pertf.r $path_to_piq/common.r $path_to_pwm $dir_out_tmp $dir_out_call $file_bam_rdata $idx
done
