# oligoN-design
  
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17534896.svg)](https://doi.org/10.5281/zenodo.17534896) [![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](http://bioconda.github.io/recipes/oligon-design/README.html)
  
The purpose of this tool is to help the user design specific oligonucleotide, to be later used as probes for Fluorescence *in situ* Hybridisation (FISH) or primers for PCR amplification. It focuses on Small SubUnit (SSU) of the rDNA operon (18S rDNA and 16S rDNA), but can potentially be used for other genes.  
  
For a detailed documentation of the OligoN-design tool, please see the [documentation](oligoN-design_documentation.pdf).  
  
![brief_pipeline](/resources/bioinfo_pipeline_summary.png)   
  
## Installation  
OligoN-design is available from [bioconda](https://bioconda.github.io/recipes/oligon-design/README.html), and the simplest option to install oligoN-design is to use [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html) (or [conda](https://docs.conda.io/projects/conda/en/stable/) or [mamba](https://mamba.readthedocs.io/en/latest/)). So before starting, please make sure you have micromamba installed.  
Once micromamba is installed, open the bash terminal, go to your preferred environment and run:  
```bash  
micromamba install oligon-design  
```    
  
Otherwise, you can create a new environment as follows:
```bash  
micromamba create --name oligoNenv oligon-design  
```
Then simply activate the environment to run oligoN-design functions (```micromamba activate oligoNenv```  ), and deactivate it to exit (‘```micromamba deactivate```’).  
Please, note that you can replace ```oligoNenv``` by the environment name of your choice.

For further information about installation, see the [bioconda](https://bioconda.github.io/recipes/oligon-design/README.html) webapge.  
  
## Running  
After activating the oligoN-design environment, you can start running the functions as follow:
```bash  
oligoNdesign -t target.fasta -e excluding.fasta -o oligos  
```    
  
## Citing
If you use the oligoN-design tool to either design specific oligonucleotides, or to help you design specific oligonucleotides, please cite the following manuscript where we report this software:  
  
Sandin MM, Walde M, Henry N, Berney C, Simon N, Forn I, Massana R, Richter D (**2025**) OligoN-design: A simple and versatile tool to design specific probes and primers from large heterogeneous datasets. *bioRxiv* 2025.11.04.685038; doi: [10.1101/2025.11.04.685038](https://www.biorxiv.org/content/10.1101/2025.11.04.685038v1)  
  
## Concluding remarks
The OligoN-design tool was designed to help the design of specific oligonucleotides accommodating the large environmental datasets and with a simple and versatile approach. However, any output from this tool should be interpreted as a starting point and needs to be empirically optimized and tested.  
  
  
