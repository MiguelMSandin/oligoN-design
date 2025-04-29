# oligoN-design
  
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10688602.svg)](https://doi.org/10.5281/zenodo.10688602)
  
The purpose of this tool is to help the user design specific oligonucleotide, to be later used as probes for Fluorescence *in situ* Hybridisation (FISH) or primers for PCR amplification. It focuses on Small SubUnit (SSU) of the rDNA operon (18S rDNA and 16S rDNA), but can potentially be used for other genes.  
  
For a detailed documentation of the OligoN-design tool, please see the [documentation](oligoN-design_documentation.pdf).  
  
![brief_pipeline](/resources/bioinfo_pipeline_summary.png)   
  
## Installation  
The simplest option is to use [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html), so before starting, please make sure you have it installed.  
Once micromamba is installed, go to your preferred directory to store software, open the bash terminal and run:  
```bash  
git clone https://github.com/MiguelMSandin/oligoN-design.git  
cd oligoN-design  
micromamba env create -f oligoN-design_env.yml  
chmod +x scripts/*  
cp scripts/* $(micromamba info --base | sed ‘s/.* : //g’)/envs/oligoN-design/bin/  
```  
This will clone the repository from github, install all dependencies and add all the functions within the environment directory. Now if you want to run any function from oligoN-design, you simply have to activate the environment as follows:
```bash  
micromamba activate oligoN-design  
```  
And to exit, just deactivate the environment (‘```micromamba deactivate```’).
  
## Running  
After activating the oligoN-design environment, you can start running the functions as follow:
```bash  
oligoNdesign -t target.fasta -e excluding.fasta -o oligos  
```    
  
## Citing
We are preparing a manuscript that will soon be publicly available.  
  
## Concluding remarks
The OligoN-design tool was designed to help the design of specific oligonucleotides accommodating the large environmental datasets and with a simple and versatile approach. However, any output from this tool should be interpreted as a starting point and needs to be empirically optimized and tested.  
  
  
