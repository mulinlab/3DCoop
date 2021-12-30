#!/bin/bash

dir_bin="bin"
fi_cfg="NHEK.conf"

# Step1: ~10 minutes
perl $dir_bin/01_02_prepare4jaccard.pl $fi_cfg

# Step3: ~1.5 hours using 50 threads
perl $din_bin/03_jaccard.pl $fi_cfg
# extract Jaccard between TFs
#perl $din_bin/extract_jaccard_glasso.pl outputs/03_jaccard/jaccard_HMEC.txt CTCF SMC3 RAD21 yy1

# Step4: ~2.5 hours
Rscript $din_bin/04_glasso.R $fi_cfg

# Step5: ~0.5 hour
perl $din_bin/05_clusterone.pl $fi_cfg

# Step6: ~5 minutes
perl $din_bin/06_network.pl $fi_cfg

# Step7: ~1 minute
#perl $din_bin/../scripts/07.1_extract_cliques.pl $WORK_DIR $CELL TF1 TF2 TF3
#perl $din_bin/../scripts/07.2_extract_cliques_info.pl $WORK_DIR $CELL
#Rscript $din_bin/../scripts/07.3_plot_clique_pie.R $WORK_DIR $CELL
