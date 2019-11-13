#!/bin/bash

fi_cfg=$1
dio=$(grep "dir_out" $fi_cfg | cut -f2)
dio="$dio/05_clusterone"
din_cluster="$dio/03_clusters"
din_clique="$dio/05_max_cliques"
din_pair="$dio/06_pairs"
din_score="$dio/07_score"
dout_result="$dio/08_results"
mkdir -p $dout_result

cells=($(grep "cells" $fi_cfg | cut -f2 | tr ',' "\n" | sort | uniq))

for cell in ${cells[@]}
do
  ln $din_cluster/${cell}_clusters_all.txt $dout_result/${cell}_clusters_list.txt
  ln $din_clique/${cell}_max_cliques.txt $dout_result/${cell}_max_cliques.txt
  ln $din_pair/${cell}_pairs.txt $dout_result/${cell}_pairs.txt
  ln $din_score/${cell}_cluster_scores.txt $dout_result/${cell}_clusters_score.txt
done
