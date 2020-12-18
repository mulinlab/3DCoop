#!/bin/bash

conda create -n 3DCoop

conda activate 3DCoop

# conda install perl-db-file bedtools
conda install bedtools perl-list-moreutils perl-parallel-forkmanager r-tidyverse r-reshape r-huge r-igraph r-desctools r-ggnetwork r-intergraph

conda deactivate 3DCoop
