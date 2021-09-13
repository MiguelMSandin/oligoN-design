# oligoN-design (version alpha)
  
The purpose of this pipeline is to produce oligonucleotide candidates to be used for PCR amplification (primers) or FISH (probes) among other uses. It focuses on the rDNA operon (specially the Small-SubUnit of the rDNA or the 18S rDNA gene), yet it can potentially be used for other genes.  
  
Briefly, this pipeline takes a **target** [fasta](https://en.wikipedia.org/wiki/FASTA) file and searches for specific regions of the sequences against a **reference** fasta file. Later, based on the specificity, GC content, theoretical melting temperature and the accessibility of the selected region the best primers/probes are manually selected.  
  
![brief_pipeline](/resources/bioinfo_pipeline_ppt.png)  
  
>(For further details on the pipeline, please check the [detailed pipeline](/resources/bioinfo_pipeline.pdf) in the resources folder.  
  
## Dependencies  
- [python](https://www.python.org/)  
    -   **Required modules**: argparse, Bio, regex, re, networkx, pandas, re, sys.  
- [mafft](https://mafft.cbrc.jp/alignment/software/)  
- An alignment editor software, such as [aliview](https://ormbunkar.se/aliview/) or [seaview](http://doua.prabi.fr/software/seaview)  
### In-house dependencies
- [sequenceSelect.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/sequenceSelect.py)  
- [alignmentConsensus.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/alignmentConsensus.py)  
  
Download and move the scripts to you prefered folder (e.g.;`/usr/lobal/bin/`). You might need to make the scripts executable as follows: `chmod +x *.py`.
  
## Quick start  
If you already have a target fasta file and a reference fasta file (note that the reference file **should not** contain sequences associated to your targeted group), the simplest pipeline is as follows:

`findPrimer.py -t target.fasta -r reference.fasta -o output`  
`testPrimer.py -r reference.fasta -f output.fasta -o output_TP.tsv`  
`mafft target.fasta > target_align.fasta`  
`alignmentConsensus.py -f target_align.fasta -o target_consensus.fasta`  
`mafft --addfragments output.fasta target_consensus.fasta > target_consensus_regions.fasta`
  
And based on your preferred parameters you select the best candidate regions for preliminary laboratory experiments.  

## Getting started
First decide on which organism/group you want to be working with, in this example we are going to be focusing on the Diatom *Guinardia*.  
Then, choose your favourite reference file. In this example we are going to be using public data, for example let's use the [PR2 database](https://pr2-database.org/). Go to your working directory, download and unzip the file:  
  
`wget https://github.com/pr2database/pr2database/releases/download/v4.14.0/pr2_version_4.14.0_SSU_taxo_long.fasta.gz`  
`gunzip -k pr2_version_4.14.0_SSU_taxo_long.fasta.gz`  

## Prepare files
Now create the **target** and **reference** fasta files. To do so, we extract all sequences affiliated to *Guinardia* from the reference database and save them into the target file. We could do this with the script [sequenceSelect.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/sequenceSelect.py) as follows:  
  
`sequenceSelect.py -f pr2_version_4.14.0_SSU_taxo_long.fasta -o target.fasta -p Guinardia -a k -v`  
`sequenceSelect.py -f pr2_version_4.14.0_SSU_taxo_long.fasta -o reference.fasta -p Guinardia -a r -v`  
  
>**Note**: The target file might be created faster by using grep (`grep -A 1 Guinardia pr2_version_4.14.0_SSU_taxo_long.fasta > target.fasta`). Yet, the fasta file has to be saved with the sequences in one line, and not in several lines. You could use this [script](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/multi2linefasta.py) to change a multi-line fasta to single_line fasta if needed.  

## Find specific regions  
Once we have the target and reference files, we are going to **search for specific regions** of different length in the target file that are not in the reference file. It is important to know that:  
- Not all sequences in a database are of the same length, and therefore the region of interest might not be present in all sequences from the target file.
- Despite enourmous and unvaluable efforts in manually curating reference databases, taxonomic annotation is not perfect. So it is possible that the region of interest might also be present in the reference file.  
  
With this in mind, we can search for specific regions using the script **[findPrimer.py](https://github.com/MiguelMSandin/oligoN-design/tree/main/scripts/findPrimer.py)** as follows:  
  
`findPrimer.py -t target.fasta -r reference.fasta -o guinardia_PR2_m8_s001 -l '18+22' -m 0.8 -s 0.001 -v`  
  
With this command we are looking for regions of 18, 19, 20, 21 and 22 base pairs (bp: `-l '18+22'`) that are present in at least 80% (`-m 0.8`) of the sequences in the target file (`-t target.fasta`) and that are present in less than 0.001% (`-s 0.001`) in the reference file (`-r reference.fasta`). In order to carry out different searches, we have saved the output file name with key parameters of the search (`-o guinardia_PR2_m8_s001`).  
  
>**Note1**: For further details on the usage of the script, use the help `findPrimer.py -h`.  

## Test regions
Regions found in the previous step are now going to be tested for hits **allowing mismatches** against the same reference database as follows:  
  
`testPrimer.py -r reference.fasta -f guinardia_PR2_m8_s001.fasta -o guinardia_PR2_m8_s001_TP_m2.tsv -m 2 -v`  
  
Here we are using the fasta file generated in the previous step and containing all potential primers/probes (`-f guinardia_PR2_m8_s001.fasta`) to look if its present in the reference file (`-r reference.fasta`) allowing 0, 1 and 2 mistmatches (`-m 2`). Again, we save the output file with parameters of the command (`-o guinardia_PR2_m8_s001_TP_m2.tsv`).  
  
If you are interested in further exploring the hits allowing mismatches of a specific primer/probe you could use the wrapper script [extractMismatches.sh](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/wrappers/extractMismatches.sh).
  
## Generate a consensus sequence of the target file
First we have to align the file:  
  
`mafft target.fasta > target_align.fasta`  
  
Might be worth checking the alignment manually for possible missalignments. From the aligned file, we can now build a consensus sequence as follows:  
  
`alignmentConsensus.py -f target_align.fasta -o target_consensus.fasta -t 70 -b 30 -g 80 -r -m -v`  
  
The consensus sequences is using a 70% consensus threshold (`-t 70`), considering bases that are present in at least 30% of the sequences (`-b 30`) and considering gaps if a position contains more than 80% of gaps (`-g 80`). In this example we are using the most abundant base (`-m` option) to resolve ambiguities and removing gaps in the output sequence (`-r` option) to be used for downstream analysis. However you can go fancy and use different thresholds in order to have a better representation of the diversity within the group using the wrapper script [alignmentConsensus_compare.sh](https://github.com/MiguelMSandin/oligoN-design/tree/main/scripts/wrappers/alignmentConsensus_compare.sh).  

## Align candidate regions to consensus sequence
With this step we just want to know in what positions of the 18S rDNA gene the candidate regions are:  
  
`mafft --addfragments guinardia_PR2_m8_s001.fasta target_consensus.fasta > target_consensus_regions.fasta`

## Estimate the secondary structure
### (to be implemented)
By using the recentlmy develop tool [R2DT](https://github.com/rnacentral/R2DT) ([Sweeney et al., 2021](https://www.nature.com/articles/s41467-021-23555-5#citeas) ), we can infer the secondary structure of (almost) any 18S rDNA. An easy example of using this tool can be uploading the consensus sequence created in the previous step to the [R2DT website](https://rnacentral.org/r2dt) an automatically generate the secondary structure of the rDNA by comparing to the best fitting profile.  

## Identify best accesibility regions
### (to be implemente)
Little effort has been done in this area of research, yet Behrens et al. ([2003](https://journals.asm.org/doi/10.1128/AEM.69.3.1748-1758.2003)) provide an excellent map of the probe accessibility for the eukaryotic 18S rDNA gene of *Saccharomyces cerevisiae*. Further, Bernier et al. ([2018](https://academic.oup.com/mbe/article/35/8/2065/5000151)) provide a 3D reconstruction and highly preserved domains of the rDNA operon.  

## Identification of the best candidate primers/probes
### (to be implemented)
By integrating the length, GC content, theoretical melting temperature and number of hits allowing mismatches obtained in this pipeline, along with the accesibility of the desire region, it is possible to **manually select the best candidate primers/probes** for your group. In this sense you want to select 2-4 primers/probes in order to **empirically test and cross-validate its specificity and functioning**, and therefore you will target candidate primers/probes:
- that covers most of the targeted diversity,
- with a high GC content,
- with similar theoretical melting temperature,
- with low hits to the reference file allowing mismatches (or at least that hits to a known group, i.e.; copepods),
- highly accessible,
- and that avoids self-binding (**to be implemented**, i.e.; ACGTnnnnACGT).

## References
-Behrens S, Rühland C, Inácio J, Huber H, Fonseca A, Spencer-Martins I, Fuchs BM, Amann R. In situ accessibility of small-subunit rRNA of members of the domains Bacteria, Archaea, and Eucarya to Cy3-labeled oligonucleotide probes. Appl Environ Microbiol. 2003 Mar;69(3):1748-58. doi: [10.1128/AEM.69.3.1748-1758.2003](https://journals.asm.org/doi/10.1128/AEM.69.3.1748-1758.2003)  
-Bernier CR, Petrov AS, Kovacs NA, Penev PI, Williams LD. Translation: The Universal Structural Core of Life. Mol Biol Evol. 2018 Aug 1;35(8):2065-2076. doi: [10.1093/molbev/msy101](https://academic.oup.com/mbe/article/35/8/2065/5000151)  
-Sweeney, B.A., Hoksza, D., Nawrocki, E.P. et al. R2DT is a framework for predicting and visualising RNA secondary structure using templates. Nat Commun 12, 3494 (2021). doi:[10.1038/s41467-021-23555-5](https://www.nature.com/articles/s41467-021-23555-5#citeas)  
