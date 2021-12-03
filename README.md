# 3DCoop

*Inferring cell type-specific transcriptional regulators cooperation in the context of 3D chromatin*

## Overview

The intact cooperation of transcriptional regulators (TRs), including transcription factors, histone modifying enzymes and chromatin remodellers, precisely determine gene expression in the cell nucleus. Deciphering the relationship among these TRs in the context of 3D chromatin and specific cell type will facilitate the understanding of transcriptional regulation.

3DCoop is a computational tool to detect genome-wide and cell type-specific TRs cooperation in 3D mode (and 1D mode), by incorporating 3D chromatin interactions (required for 3D mode) and TRs' footprinting. Results from 3C-based technologies (Hi-C, PCHi-C, ChIA-PET, HiChIP, *et al.*) can be used as the 3D chromatin interactions. The TR's footprinting can be collected from ChIP-seq data, or be predicted by [PIQ](http://piq.csail.mit.edu) (incorporated in this repo) or similar tools using DNase/ATAC-seq and TRs' motifs. We have collected TRs' motifs from several resources as described in **3DCoop publication**. The human and mouse TR motifs which can be used in the PIQ pipeline have been incorporated in the `resource` folder.

## Installation

The environment of 3DCoop is build using conda, so please make sure the conda has been installed and configured. The [bioconda document](https://bioconda.github.io/user/install.html) can be referenced.

Then, you can install 3DCoop through:

```bash
cd ~
git clone https://github.com/mulinlab/3Dcoop
cd 3Dcoop
bash conda.sh
```

A conda environment named `3DCoop` has been created. To use 3DCoop pipeline, this environment should be activated by:

```shell
conda activate 3DCoop
```

The corresponding deactivate command is:

```shell
conda deactivate 3DCoop
```

## Usage

After installation of 3DCoop, this pipeline can be used with prepared input files and a configure file. The details of preparing and running are described in the [usage manual](./usage.md).

## Credits
3Dcoop was written by Xianfu Yi, member of the Mulin group.

For any question about 3DCoop, please contact yixfbio AT gmail DOT com.

## Citation

If you use 3DCoop, please cite:

Yi Xianfu, Zheng Zhanye, Xu Hang, Zhou Yao, Huang Dandan, Wang Jianhua, Feng Xiangling, Zhao Ke, Fan Xutong, Zhang Shijie, Dong Xiaobao, Wang Zhao, Shen Yujun, Cheng Hui, Shi Lei, Li Mulin Jun. Interrogating cell type-specific cooperation of transcriptional regulators in 3D chromatin. *iScience*. 2021;24:103468. doi:10.1016/j.isci.2021.103468. <https://www.sciencedirect.com/science/article/pii/S2589004221014395>

