# Frequently Asked Questions (FAQ) about conda

1. `conda` can't be used, or the conda environment  can't be activated using `conda`. The error might be `CommandNotFoundError: Your shell has not been properly configured to use 'conda deactivate'`.

   There are several reasons for this. But you can try the following actions one-by-one (suppose the [Miniconda](https://docs.conda.io/en/latest/miniconda.html) is installed).

   1. Restart the shell by opening a new terminal or activate `conda` for the current session with:

      ```
      source $HOME/miniconda3/bin/activate
      ```
   
   2. Add `conda` to the `$PATH` variable:
   
      ```
      cat 'export PATH="$HOME/miniconda3/bin:$PATH"' >> $HOME/.bashrc
      source $HOME/.bashrc
      ```
      
   2. Enable the automatic base environment activation with:
   
      ```
      conda config --set auto_activate_base true
      ```
      
    4. Use `source activate` and `source deactivate` instead of `conda activate` and `conda deactivate`.
   
    5. Read and follow the detailed installation instruction, such as:
   
       * [Installation — conda documentation](https://conda.io/projects/conda/en/latest/user-guide/install/index.html)
       * [Installing on Linux — Anaconda documentation](https://docs.anaconda.com/anaconda/install/linux/)
       * [Python Installation - Conda Install](https://developers.google.com/earth-engine/guides/python_install-conda)
   
2. The 3DCoop environment can't be setting up successfully.

   To make it easier to find out which software installation is making the installation process difficult, you can install them one-by-one.
   ```
   conda create -n 3DCoop                               # Create the environment
   
   conda activate 3DCoop                                # Activate the environment
   
   conda install -c bioconda bedtools                   # Install bedtools
   conda install -c bioconda samtools                   # Install samtools
   conda install -c bioconda perl-list-moreutils        # Install Perl package, List::MoreUtils
   conda install -c bioconda perl-parallel-forkmanager  # Install Perl package, Parallel::ForkManager
   conda install -c r r-tidyverse                       # Install R package, tidyverse
   conda install -c r r-reshape                         # Install R package, reshape
   conda install -c conda-forge r-huge                  # Install R package, huge
   conda install -c conda-forge r-igraph                # Install R package, igraph
   conda install -c conda-forge r-desctools             # Install R package, DescTools
   conda install -c conda-forge r-ggnetwork             # Install R package, ggnetwork
   conda install -c conda-forge r-intergraph            # Install R package, Intergraph
   
   conda deactivate 3DCoop                              # Deactivate the environment
   ```