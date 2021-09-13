# oligoN-design (version alpha)
  
The purpose of this pipeline is to produce oligonucleotide candidates to be used for PCR amplification (primers) or FISH (probes) among other uses. It focuses on the rDNA operon (specially the Small-SubUnit of the rDNA or the 18S rDNA gene), yet it can potentially be used for other genes.  
Briefly, this pipeline takes a **target** [fasta](https://en.wikipedia.org/wiki/FASTA) file and searches for specific regions of the sequences against a **reference** fasta file. Later, based on the specificity, GC content, theoretical melting temperature and the accessibility of the selected region the best primers/probes are manually selected.  
  
![brief_pipeline](/resources/bioinfo_pipeline_ppt.png)  
  
>(For further details on the pipeline, please check the [detailed pipeline](/resources/bioinfo_pipeline.pdf) in the resources folder.  
  
## Dependencies  
- [python](https://www.python.org/)  
    -   **Required modules**: argparse, Bio, regex, re, networkx, pandas, re, sys.  
### In-house dependencies
- [sequenceSelect.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/sequenceSelect.py)  
  
Download and move the scripts to you prefered folder (e.g.;`/usr/lobal/bin/`). You might need to make the scripts executable as follows: `chmod +x *.py`.
  
## Quick start  
First decide on which organism/group you want to be working with, in this example we are going to be focusing on the Diatom *Guinardia*.  
Choose your favourite reference file, for example let's use the [PR2 database](https://pr2-database.org/). Go to your working directory, download and unzip the file:  
`wget https://github.com/pr2database/pr2database/releases/download/v4.14.0/pr2_version_4.14.0_SSU_taxo_long.fasta.gz`  
`gunzip -k pr2_version_4.14.0_SSU_taxo_long.fasta.gz`  

### Prepare files
Now create the **target** and **reference** fasta files. To do so, we extract all sequences affiliated to *Guinardia* from the reference database and save them into the target file. We could do this with the script [sequenceSelect.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/sequenceSelect.py) as follows:  
`wget `  
`scripts/sequenceSelect.py -f pr2_version_4.14.0_SSU_taxo_long.fasta -o target.fasta -p Guinardia -a k -v`  
`scripts/sequenceSelect.py -f pr2_version_4.14.0_SSU_taxo_long.fasta -o reference.fasta -p Guinardia -a r -v`  
  
>**Note**: The target file might be created faster by using grep (`grep -A 1 Guinardia pr2_version_4.14.0_SSU_taxo_long.fasta > target.fasta`). Yet, the fasta file has to be saved with the sequences in one line, and not in several lines. You could use this [script](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/multi2linefasta.py) to change a multi-line fasta to single_line fasta if needed.  

### Find specific regions  
Once we have our target and reference file, we are going to search for specific regions of different length in the target file that are not in the reference file. It is important to know that:  
- Not all sequences in a database are of the same length, and therefore the region of interest might not be present in all sequences from the target file.
- Despite enourmous and unvaluable efforts in manually curating reference databases, taxonomic annotation is not perfect. So it is possible that the region of interest might also be present in the reference file.  
  
With this in mind, we can search for specific regions using the script **[findPrimer.py](https://github.com/MiguelMSandin/oligoN-design/tree/main/scripts/findPrimer.py)** as follows:  
`scripts/findPrimer.py -t target.fasta -r reference.fasta -o guinardia_PR2_m8_s001 -l '18+22' -m 0.8 -s 0.001 -v`  
Briefly, with this command we are looking for regions of 18, 19, 20, 21 and 22 base pairs (bp: `-l '18+22'`) that are present in at least 80% (`-m 0.8`) of the sequences in the target file (`-t target.fasta`) and that are present in less than 0.001% (`-s 0.001`) in the reference file (`-r reference.fasta`). In order to carry out different searches, we have saved the output file name with key parameters of the search (`-o guinardia_PR2_m8_s001`).  
  
>**Note1**: For further details on the usage of the script, use the help `findPrimer.py -h`.  


