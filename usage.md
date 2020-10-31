# 3DCoop usage manual

The 3DCoop pipeline is recommended to running in a certain folder for each project. Here we use the `project_3DCoop_test` as the project folder, so we change to the folder firstly:

```shell
cd project_3DCoop_test
```

Two datasets for testing, one for 3D mode and one for 1D mode, has been included in the 3DCoop pipeline, which can be found in the `test` folder. Besides, the configure file and pipeline running script are included in the `test` folder, and can be referred by users.

The details of input files, configure file, and pipeline running steps will be described in this manual.

## Input files

Two types input data (`interactions` and `peaks` for 3D mode and only `peaks` for 1D mode) are needed for 3DCoop, so we organize them in one folder named `inputs`:

```shell
mkdir inputs
cd inputs
mkdir interactions peaks
```

###  data of peaks

The peaks are organized for each tissue/cell type, so make directory for each tissue or cell, and put all peaks file in this directory. Here we call the tissue/cell type as `CELLID` for short.

The peaks are stored in files, and one file for each TR. The peak file is in BED format with at least 3 columns (chromosome, start and end position) and must be named as ` CELLID_TRID.bed`. The `CELLID` and `TRID` should be changed to real tissue/cell type name and TR name, respectively.

### data of interactions

The interactions should be prepared in two formats, `BEDPE` and `BED` format. 

#### BEDPE file

The `BEDPE` file should contain 8 columns: `chr1`, `start1`, `end1`, `chr2`, `start2`, `end2`, `interaction ID`, and `interaction score`. The last column, that is `interaction score` can set to 1 when no interaction score is available.

#### BED file

The `BED` file is generated from `BEDPE` file using the `bedpe2bed.pl` in the `bin` folder:

```shell
perl DIR_TO_3DCoop/bin/bedpe2bed.pl DIR_TO_BEDPE
```

## Configure file

A configure file is needed for pipeline running. This configure file can be renamed as you wanted, and the name will be used when running pipeline. Here the name of `3DCoop_test.cfg` is used for example.

The configure file is a text file with 2 columns and several rows using the `TAB` as the separator. Multiple values should be separated by `,`.  An example is showing:

```
key	value
species	human
mode	3D
dir_in	inputs
dir_out	outputs
cells	K562
fraction	1
cpus	20
cutoffs	0.05
extract_clique	no
pie	true
```

Each key in the first column and its values is explained:

* `species`: `human` or `mouse`.
* `mode`: `3D` for 3D mode and `1D` for 1D mode.
* `dir_in`: directory for input files, which including peaks and/or interactions for 3D mode or 1D mode.
* `dir_out`: the results will be stored  here.
* `cells`:  ID of tissues or cell types. Multiple ID can be specified by separated using `,`, such as `K562,GM12878,KBM7`.
* `fraction`: a minimal overlap fraction of peak to assign it to a certain interaction. Multiple values can be specified by separated using `,`. Make sure the length is same to length of `cells`.
* `cpus`: number of threads will be used. `cells` can use different `cpus`, but make sure they have the same length.
* `cutoffs`: the cutoff used for ClusterONE for clusters extraction. `auto` can be used to define the cutoff automatically. `cells` can use different `cutoffs`, but make sure they have the same length.
* `extract_clique`: extract cliques from clusters, the values are `yes` or `no`. `no` is recommended because it will use huge memory and days to extract cliques from large clusters.
* `pie`: display pie chart for each TR, the values are `true` or `false`. Make sure use `false` for `mouse`, and `true` or `false` for `human` as you wanted.

## Running pipeline

Make sure the conda environment (`3DCoop` as example) has been activated before running the pipeline.

The 3DCoop pipeline is running in steps:

```shell
# STEP1: prepare data for Jaccard calculation
perl DIR_TO_BIN/01_02_prepare4jaccard.pl FILE_OF_CFG
# STEP2: Calculate the Jaccard
perl DIR_TO_BIN/03_jaccard.pl FILE_OF_CFG
# STEP3: Run GLASSO based on Jaccard values
perl DIR_TO_BIN/04_glasso.R FILE_OF_CFG
# STEP4: Run ClusterONE based on GALSSO results
perl DIR_TO_BIN/05_clusterone.pl FILE_OF_CFG
# Visualize the TR cooperation network
perl DIR_TO_BIN/06_network.pl FILE_OF_CFG
```

Here, the `DIR_TO_BIN` is the path to the `bin` directory of the pipeline. The `FILE_OF_CFG` is the path to the configure file, such as `3DCoop_test.cfg`.

## Output results

Six folders corresponding to each step will be generated in the output directory which is specified in the configure file.

* `01_intersection_bed`: the results in `BED` format  by intersecting peaks and interactions.
* `02_intersection_bedpe`: the results in `BEDPE` format  by intersecting peaks and interactions. This folder is not avaliable for 1D mode.
* `03_jaccard`: the Jaccard results for TR cooperation.
* `04_glasso`: the GLASSO results for TR cooperation.
* `05_clusterone`: the results of ClusterONE. There are several folder in this directory, but the folder named `08_results` is the final results you will need.
* `06_network`: TR cooperation networks in `PDF` and `PNG` format.

As mentioned, the files in `05_clusterone/08_results` is the key results for users. There are 4 files which all use the tissue/cell type name as the prefix:

* `CELLID_clusters_list.txt`: list of clusters, one cluster per row, and the TRs in a cluster are separated by `TAB`.
* `CELLID_clusters_score.txt`: scores for each cluster, including cluster size, mean density, GLASSO score, and so on.
* `CELLID_max_cliques.txt`: maximum cliques extracted from clusters, and related scores including Jaccard and GLASSO.
* `CELLID_pairs.txt`: TR pairs extracted from clusters, and related score including Jaccard and GLASSO.

## Miscellaneous scripts

### `bedpe2bed.pl`

This script can transform the `BEDPE` format to unique `BED` format as described previously. It can be used by:

```shell
# perl bedpe2bed.pl <DIR (containing one or more BEDPE files)>
perl DIR_TO_3DCoop/bin/bedpe2bed.pl DIR_TO_BEDPE
```

### `extract_jaccard_glasso.pl`

This script can extract pair-wise results of Jaccard or GLASSO for multiple TRs from the intermediate results. It can be used by:

```shell
# perl extract_jaccard_glasso.pl <FILE> <TRS (no matter numbers and cases of TRs name)>
perl DIR_TO_3DCoop/bin/extract_jaccard_glasso.pl DIR_TO_OUPTUT/03_jaccard/jaccard_CELLID.txt CTCF RAD21 SMC3
perl DIR_TO_3DCoop/bin/extract_jaccard_glasso.pl DIR_TO_OUPTUT/04_glasso/glasso_CELLID.txt ctcf Rad21 SMC3 YY1
```

