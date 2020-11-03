#!/bin/bash

dir_bin="bin"
fi_cfg="NHEK.conf"

# Step1: ~10 minutes per cell
perl $dir_bin/01_intersect_interactions_peaks.pl $fi_cfg

# Step2: ~20 minutes per cell
perl $dir_bin/02_class_intersections.pl $fi_cfg

# Step3: ~1.5 hours per cell using 50 threads
perl $din_bin/03_jaccard_in_parrallel.pl $fi_cfg
# extract Jaccard between TFs
#perl $din_bin/extract_jaccard_glasso.pl outputs/03_jaccard/jaccard_HMEC.txt CTCF SMC3 RAD21 yy1


# Step4: ~2.5 hours per cell
Rscript $din_bin/04_glasso.R $fi_cfg

# Step5: ~0.5 hours per cell
perl $din_bin/05_clusterone.pl $fi_cfg
# # Step5.1 & 5.2: ~5 minutes per cell
# perl $din_bin/05.1_ClusterONE_test.pl $fi_cfg
# # Step5.3: seconds per cell
# perl $din_bin/05.3_get_clusters.pl $fi_cfg
# # Step5.4: ~10 minutes per cell
# #perl $din_bin/05.4_extract_clique.pl $fi_cfg
# # Step5.5: ~5 minutes per cell
# perl $din_bin/05.5_extract_max_clique.pl $fi_cfg
# # Step5.6: seconds per cell
# perl $din_bin/05.6_maxclique2pair.pl $fi_cfg
# # Step5.7: ~seconds per cell
# perl $din_bin/05.7_score_clutser.pl $fi_cfg
# # Step5.8: ~seconds per cell
# bash $din_bin/05.8_collect_results.sh $fi_cfg

# Step6: ~5 minutes per cell
perl $din_bin/06_network.pl $fi_cfg
# # Step6.1: seconds per cell
# perl $din_bin/06.1_complex2network.pl $fi_cfg
# # Step6.2: seconds per cell
# perl $din_bin/06.2_prepare4pie.pl $fi_cfg
# # Step6.3: ~5 minutes per cell
# Rscript $din_bin/06.3_plot_network.R $fi_cfg

# Step7: ~1 minutes per cell
perl $din_bin/07.1_extract_cliques.pl $WORK_DIR $CELL TF1 TF2 TF3
perl $din_bin/07.2_extract_cliques_info.pl $WORK_DIR $CELL
Rscript $din_bin/07.3_plot_clique_pie.R $WORK_DIR $CELL
