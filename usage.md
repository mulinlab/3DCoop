# 3DCoop usage manual

The 3DCoop pipeline is recommended to run in a certain folder for each project. Here we use the `project_3DCoop_test` as the project folder, so we change into the folder firstly:

```shell
cd project_3DCoop_test
```

Two datasets for testing, one for 3D mode and one for 1D mode, has been included in the repo. They can be found in the `test` folder. Besides, the configuration file and pipeline running script are provided in the `test` folder. Thet can be referred by users.

The details for inputs, configuration file, and pipeline running steps will be described in this manual.

## Inputs

Two types of input datasets (`interactions` and `peaks` for 3D mode while only `peaks` for 1D mode) are needed for 3DCoop, so we organize them in one folder named `inputs`:

```shell
mkdir inputs
cd inputs
mkdir interactions peaks
```

###  Data of peaks

The peaks or TR binding events are organized for each tissue/cell type. Please make directory for each tissue or cell type, and put all files of peaks in this directory. Here we call the tissue/cell type as `CELLID` for short.

The peaks are stored in files, one file per TR. The peak file is in BED format with at least 3 columns (chromosome, start and end position) and must be named as ` CELLID_TRID.bed`, such as `K562_CTCF.bed`. The `CELLID` and `TRID` should be changed to real tissue/cell type name and TR name, respectively.

### Data of interactions

The chromatin interactions or chromatin loops should be prepared in two formats, `BEDPE` and `BED` format. 

#### BEDPE file

This file stores the chromatin loops. The `BEDPE` file should contain 8 columns: `chr1`, `start1`, `end1`, `chr2`, `start2`, `end2`, `interaction ID/name`, and `interaction score`. The last column, that is `interaction score`, can be set to 1 when no interaction score is available. The `BEDPE` file should be named as `CELLID.bedpe`, such `K562.bedpe`.

#### BED file

This file stores the genomic intervals from chromatin loops. The `BED` file can be got from `BEDPE` file using the `bedpe2bed.pl` in the `bin` folder. A file named `CELLID.bed` will be generated besides `CELLID.bedpe`, such as `K562.bed` besides `K562.bedpe`.

```shell
perl DIR_TO_3DCoop/bin/bedpe2bed.pl DIR_TO_BEDPE
```

## Configuration file

A configuration file to tune the whole pipeline is needed. This configuration file can be renamed as users want, and the given name will be passed as a parameter to the scripts when running pipeline. Here the name `3DCoop_test.cfg` is used for example.

The configuration file is a text file with 2 columns and several rows using the `TAB` as the separator. Multiple values should be separated by `,`.  Here is an example:

```
key	value
species	human
mode	3D
build	hg19
binsize	5kb
dir_in	inputs
dir_out	outputs
cells	K562
fraction	1
cpus	20
cutoffs	0.05
extract_clique	no
pie	true
```

The keys in the first column and corresponding values in the second column are explained:

* `species`: `human` or `mouse`.
* `mode`: `3D` for 3D mode and `1D` for 1D mode.
* `build`: genome build name. *Only* required for 1D mode, such as `hg19`, `hg38`, `mm10`.
* `binsize`: genome bin size name. *Only* required for 1D mode, such as `5kb`, `1Mb`.
* `dir_in`: directory for inputs. It should include peaks and interactions for 3D mode, and only peaks or 1D mode.
* `dir_out`: the results will be stored here.
* `cells`:  ID of tissues or cell types. Multiple IDs can be specified by separating using `,`, such as `K562,GM12878,KBM7`.
* `fraction`: a minimal overlap fraction of peak to assign it to a certain interaction. Multiple values can be specified by separated using `,`. *Make sure* the length is same to length of `cells`.
* `cpus`: number of threads. `cells` can use different `cpus`, but *make sure* they have the same length.
* `cutoffs`: the cutoff used in ClusterONE for clusters extraction. `auto` can be used to define the cutoff automatically. `cells` can use different `cutoffs`, but *make sure* they have the same length.
* `extract_clique`: extract cliques from clusters. The values are `yes` or `no`, and `no` is recommended because it will use huge memory and days to extract cliques from large clusters.
* `pie`: display pie chart for each TR to indicate TR categories. The values are `true` or `false`. Make sure use `false` for `mouse`, and `true` or `false` for `human` as users want.

## Run pipeline

Make sure the conda environment (`3DCoop` as example) has been activated before running the pipeline.

The 3DCoop pipeline is running in sequential steps:

```shell
# STEP1: prepare data for Jaccard calculation
perl DIR_TO_BIN/01_02_prepare4jaccard.pl FILE_OF_CFG
# STEP2: Calculate the Jaccard for TR pairs
perl DIR_TO_BIN/03_jaccard.pl FILE_OF_CFG
# STEP3: Run Glasso based on Jaccard values to estimate the precision matrix 
Rscript DIR_TO_BIN/04_glasso.R FILE_OF_CFG
# STEP4: Run ClusterONE based on GALSSO results to identify TR clusters
perl DIR_TO_BIN/05_clusterone.pl FILE_OF_CFG
# STEP55: Visualize the TR cooperation network
perl DIR_TO_BIN/06_network.pl FILE_OF_CFG
```

Here, the `DIR_TO_BIN` is the path to the `bin` directory of the pipeline. The `FILE_OF_CFG` is the path to the configuration file, such as `3DCoop_test.cfg`.

## Outputs

Six folders corresponding to each step will be generated in the output directory which is specified in the configuration file.

* `01_intersection_bed`: the results in `BED` format by intersecting peaks and chromatin interactions.
* `02_intersection_bedpe`: the results in `BEDPE` format by intersecting peaks and chromatin interactions. This folder is not avaliable for 1D mode.
* `03_jaccard`: the Jaccard results (TR pair-wise correlation matrix based on the generalized Jaccard similarity) for TR pairs.
* `04_glasso`: the Glasso results (precision matrix) for TR cooperation.
* `05_clusterone`: the results from ClusterONE and modularity analysis of TR cooperation. There are several folders in this directory, but the folder named `08_results` is the final results that users will need.
* `06_network`: TR cooperation networks in `PDF` and `PNG` format.

As mentioned, the files in `05_clusterone/08_results` are the key results for users. There are 4 files which all use the tissue/cell type name as the prefix:

* `CELLID_clusters_list.txt`: list of TR clusters, one cluster per row, *without* header. The TRs in a cluster are separated by `TAB` and sorted in alphabetical order.
* `CELLID_clusters_score.txt`: scores for each cluster including cluster size, mean density, Glasso score, and so on, with the first line as the header.
* `CELLID_max_cliques.txt`: TR maximum cliques extracted from clusters and related scores including Jaccard and Glasso, with the first line as the header.
* `CELLID_pairs.txt`: TR pairs extracted from clusters and related score including Jaccard and Glasso, with the first line as the header.

## Miscellaneous scripts

### `bedpe2bed.pl`

This script can break chromatin loops into genomic intervals as described previously, that is, transform the `BEDPE` format to unique `BED` format. It can be used by:

```shell
# perl bedpe2bed.pl <DIR (containing one or more BEDPE files)>
perl DIR_TO_3DCoop/bin/bedpe2bed.pl DIR_TO_BEDPE
```

### `extract_jaccard_glasso.pl`

This script can extract pair-wise results of Jaccard or Glasso for multiple TRs from the intermediate results. It can be used by:

```shell
# perl extract_jaccard_glasso.pl <FILE> <TRS (no matter numbers and cases of TR name)>
perl DIR_TO_3DCoop/bin/extract_jaccard_glasso.pl DIR_TO_OUPTUT/03_jaccard/jaccard_CELLID.txt CTCF RAD21 SMC3
perl DIR_TO_3DCoop/bin/extract_jaccard_glasso.pl DIR_TO_OUPTUT/04_glasso/glasso_CELLID.txt ctcf Rad21 SMC3 YY1
```

### `make_genome_bins.pl`

This script can make genome bins required for 1D mode. The bins will be saved into `DIR_TO_3DCoop/resource` folder as `GENOMEBUILD_bins_BINNAME.bed` file, such as `DIR_TO_3DCoop/resource/hg19_bins_5kb.bed`. It can be used by:

```shell
# perl make_genome_bins.pl <GENOME_BUILD> <BINNAME>
perl DIR_TO_3DCoop/bin/make_genome_bins.pl hg19 1kb
perl DIR_TO_3DCoop/bin/make_genome_bins.pl mm10 1Mb
```

### `map_variant2TRpair.pl`

This script can get the variants-associated TRs and TR pairs based on the coordinate of variants. It can be used by:

```shell
# perl map_variant2TRpair.pl <FILE_OF_CFG> <CELL_NAME> <FILE_OF_VARIANTS>
perl DIR_TO_3DCoop/bin/map_variant2TRpair.pl 3DCoop_K562.cfg K562 GWAS_variants.bed
```

* The input file for variants should be in **BED format**. Only the **first 3 columns** (chromosome, start and end position) will be used for processing, while all columns will be copied into the final output file.
* The outputs will be saved in a subdirectory named `07_variants2TRs` in the main output directory.
  * `variants2TRpairs.txt` is the final output. Columns `1~N` are identical to the columns of variants, columns `N+1` and `N+2` are the associated TR and TR pairs. The last column `N+3` indicates the detection method for TR pairs, while `loop` means that it can *only* be detected by chromatin interactions but *not* reported by 3DCoop, and `3DCoop` means that it can be detected by chromatin interactions and also reported by 3DCoop.
  * `snp2peak2bin2loop.txt` contains the mapping relationship between variants, TR peaks, genome bins, and chromatin loops. The first row is a header for columns interpretation. It may be used for checking results.
  * `tmp_*.txt` are intermediate files. Users can ignore and delete them.

## Get TR motifs from databases

Nearly all databases hvae collected TR motifs for many species. Here we use the data for human (*Homo Sapiens*) as the example. The process for data of other species is similar.

### [JASPAR](https://jaspar.genereg.net/)

1. Download PFM data for [**vertebrates**](https://jaspar2018.genereg.net/download/data/2018/CORE/JASPAR2018_CORE_vertebrates_non-redundant_pfms_jaspar.txt) in [**JASPAR CORE**](https://jaspar2018.genereg.net/downloads/).

   ```
   wget -c https://jaspar.genereg.net/download/data/2022/CORE/JASPAR2022_CORE_vertebrates_non-redundant_pfms_jaspar.txt
   ```

2. Covert the format.

   ```
   # perl DIR_TO_3DCoop/bin/convert_JASPAR.pl DIR_TO_JASPAR/JASPAR_FILE.txt DIR_TO_OUTPUT/OUTPUT_FILE.txt
   perl ./bin/convert_JASPAR.pl ./resource/JASPAR2022/JASPAR2022_CORE_vertebrates_non-redundant_pfms_jaspar.txt ./resource/motif_JASPAR2022.txt
   ```

### [CIS-BP](http://cisbp.ccbr.utoronto.ca/)

1. Download data for human from [Bulk downloads page](http://cisbp.ccbr.utoronto.ca/bulk.php). For the "By Species" line, just select "Homo_sapiens" under the "Selection" column. Other options can be kept as the default. Then click "Download Species Archive!" from the "Action" column. Unzip the downloaded file, and rename the folder if you want.

2. Convert the format.

   ```
   # perl DIR_TO_3DCoop/bin/convert_CISBP.pl DIR_TO_CISBP DIR_TO_OUTPUT/OUTPUT_FILE.txt
   perl ./bin/convert_CISBP.pl ./resource/CISBP_v2 ./resource/motif_CISBPv2.txt
   ```

### [HOCOMOCO](https://hocomoco11.autosome.ru/)

1. Download matrices from [core collection (primary binding models of ABC quality)](https://hocomoco11.autosome.ru/downloads_v11) in [JASPAR format](https://hocomoco11.autosome.ru/final_bundle/hocomoco11/core/HUMAN/mono/HOCOMOCOv11_core_HUMAN_mono_jaspar_format.txt).

   ```
   wget -c https://hocomoco11.autosome.ru/final_bundle/hocomoco11/core/HUMAN/mono/HOCOMOCOv11_core_HUMAN_mono_jaspar_format.txt
   ```

2. Convert the format.

   ```
   # perl DIR_TO_3DCoop/bin/convert_HOCOMOCO.pl DIR_TO_HOCOMOCO/HOCOMOCO_FILE.txt DIR_TO_OUTPUT/OUTPUT_FILE.txt
   perl ./bin/convert_HOCOMOCO.pl ./resource/HOCOMOCOv11/HOCOMOCOv11_core_HUMAN_mono_jaspar_format.txt ./resource/motif_HOCOMOCOv11.txt
   ```

   