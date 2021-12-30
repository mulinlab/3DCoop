# 3DCoop

*Inferring cell type-specific transcriptional regulators cooperation in the context of 3D chromatin*

## Overview

The intact cooperation of transcriptional regulators (TRs), including transcription factors (TF), RNA-binding protein (RBP), chromatin remodeler, and other factors, modulate saptiotemporal gene expression in the nucleus precisely. Deciphering the relationship among these TRs in the context of 3D chromatin and specific cell type will facilitate the understanding of the complex transcriptional regulation in cell differentiation and disease development.

3DCoop is an approach for computational inference of cell type-specific TRs cooperation in 3D chromatin (and 1D mode without 3D information), by incorporating 3D chromatin interactions (required for 3D mode) and TR footprinting. Chromatin loops detected by 3C-based technologies (Hi-C, PCHi-C, ChIA-PET, HiChIP, *et al.*) can be used as the 3D chromatin interactions. The TR footprinting can be collected from ChIP-seq datasets, or be predicted by [PIQ](http://piq.csail.mit.edu) (incorporated in this repo) or similar tools using open chromatin profiles (DNase/ATAC-seq data) and TR motifs. We have collected TR motifs from several resources as described in [3DCoop publication](#Citation). The human and mouse TR motifs which can be used in the PIQ pipeline have been incorporated in the `resource` folder.

## Installation

The environment of 3DCoop is built using conda and bioconda. Please make sure the conda has been installed and configured. The [bioconda document](https://bioconda.github.io/user/install.html) can be referred for conda installation and bioconda channels setting up.

Then, you can install 3DCoop:

```bash
cd ~
git clone https://github.com/mulinlab/3Dcoop
cd 3Dcoop
bash conda.sh
```

A conda environment named `3DCoop` has been created. To use 3DCoop pipeline, this environment should be activated by:

```shell
conda activate 3DCoop
# or
source activate 3DCoop
```

The corresponding deactivate command is:

```shell
conda deactivate 3DCoop
# or
source deactivate 3DCoop
```

## Usage

After installation of 3DCoop, this pipeline can be used with prepared inputs and a configuration file. The details for preparing and running are described in the [usage manual](./usage.md).

## Credits
3Dcoop was written by Xianfu Yi, member of the Mulin group.

For any question about 3DCoop, please contact yixfbio AT gmail DOT com.

## Citation

If you use 3DCoop, please cite:

> Yi Xianfu, Zheng Zhanye, Xu Hang, Zhou Yao, Huang Dandan, Wang Jianhua, Feng Xiangling, Zhao Ke, Fan Xutong, Zhang Shijie, Dong Xiaobao, Wang Zhao, Shen Yujun, Cheng Hui, Shi Lei, Li Mulin Jun. Interrogating cell type-specific cooperation of transcriptional regulators in 3D chromatin. *iScience*. 2021, 24(12):103468. doi: [10.1016/j.isci.2021.103468](https://www.sciencedirect.com/science/article/pii/S2589004221014395). PMID: [34888502](https://pubmed.ncbi.nlm.nih.gov/34888502/); PMCID: [PMC8634045](https://www.ncbi.nlm.nih.gov/labs/pmc/articles/PMC8634045/).

