# oligoN-design

[![Generic badge](https://img.shields.io/badge/Version-1.1.0-blue.svg)](https://github.com/MiguelMSandin/oligoN-design/releases)
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](http://bioconda.github.io/recipes/oligon-design/README.html)
[![Generic badge](http://img.shields.io/badge/DOI-10.5281/zenodo.7473194-blue.svg)](https://doi.org/10.5281/zenodo.7473194)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Generic badge](http://img.shields.io/badge/Manuscript-10.1111/1755--0998.70140-blue.svg)](https://doi.org/10.1111/1755-0998.70140)
[![Generic badge](http://img.shields.io/badge/Pre--print-10.1101/2025.11.04.685038-B31B1B.svg)](https://doi.org/10.1101/2025.11.04.685038)

The purpose of this tool is to help the user design specific oligonucleotide, to be later used as probes for Fluorescence *in situ* Hybridisation (FISH) or primers for PCR amplification. It focuses on Small SubUnit (SSU) of the rDNA operon (18S rDNA and 16S rDNA), but can potentially be used for other genes.

For a detailed documentation of the OligoN-design tool, please see the [documentation](https://github.com/MiguelMSandin/oligoN-design/blob/main/oligoN-design_documentation.pdf).

![brief_pipeline](https://github.com/MiguelMSandin/oligoN-design/raw/main/resources/bioinfo_pipeline_summary.png)

## Interactive notebook (no installation required)

An interactive Jupyter notebook for this pipeline is available and can be launched directly in your browser via [Binder](https://mybinder.org) — no installation needed. Click the badge below to open it:

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/MiguelMSandin/oligoN-design/jupyter?urlpath=lab/tree/oligoN-design_interactive.ipynb)

Caveats: the first launch takes a few minutes to build the Docker image (subsequent launches are faster). Sessions time out after ~10 minutes of inactivity, and there is no persistent storage — output files are lost when the session closes so make sure you download any outputs you wish to keep. 
For large excluding FASTA files (e.g. a full PR2 or SILVA database) it may also hit the 2 GB RAM limit.

## Installation

OligoN-design is available from [bioconda](https://bioconda.github.io/recipes/oligon-design/README.html), and the simplest option to install oligoN-design is to use [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html) (or [conda](https://docs.conda.io/projects/conda/en/stable/) or [mamba](https://mamba.readthedocs.io/en/latest/)). So before starting, please make sure you have micromamba installed.  
Once micromamba is installed, open the bash terminal, go to your preferred environment and run:

```
micromamba install oligon-design  
```

Otherwise, you can create a new environment as follows:

```
micromamba create --name oligoNenv oligon-design  
```

Then simply activate the environment to run oligoN-design functions (`micromamba activate oligoNenv`), and deactivate it to exit (`micromamba deactivate`).  

Please, note that you can replace `oligoNenv` by the environment name of your choice.

## Usage

After activating the oligoN-design environment, you can start running the functions as follow:

```
sequenceSelect -f database.fasta -p pattern -o target.fasta
sequenceSelect -f database.fasta -p pattern -o excluding.fasta -r
oligoNdesign -t target.fasta -e excluding.fasta -o oligos
```

You can find other examples, suggested workflows and even "common problems and misconceptions" or "good practices" in the [documentation](https://github.com/MiguelMSandin/oligoN-design/blob/main/oligoN-design_documentation.pdf).

## Citation

If you use the oligoN-design tool to either design specific oligonucleotides, or to help you design specific oligonucleotides, please cite the following manuscript:

Sandin MM, Henry N, Diez-Vives C, Decelle J, Tirichine L, Guillou L, de Vargas C, Mahé F, Dolan L. (2026). OligoN-design: A simple and versatile tool to design specific probes and primers from large heterogeneous datasets. *Molecular Ecology Resources*, 26(3): e70140. https://doi.org/10.1111/1755-0998.70140
