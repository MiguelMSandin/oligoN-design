# oligoN-design (version alpha)
  
The purpose of this pipeline is to produce oligonucleotide candidates to be used for fluorescence *in situ* hybridisation (probes), yet primers for PCR amplification can also be searched. It focuses on the rDNA operon (specially the Small-SubUnit of the rDNA or the 18S rDNA gene), yet it can potentially be used for other genes.  
  
Briefly, this pipeline takes a **target** [fasta](https://en.wikipedia.org/wiki/FASTA) file and searches for specific regions of the sequences against a **reference** fasta file. Later, based on the specificity, GC content, theoretical melting temperature and the accessibility of the selected region the best primers/probes are selected for empirical test in the laboratory.  
  
![brief_pipeline](/resources/bioinfo_pipeline_ppt.png)   
  
## Dependencies  
- [python](https://www.python.org/)  
    -   **Required modules**: argparse, Bio, regex, re, networkx, pandas, re, sys.  
- [mafft](https://mafft.cbrc.jp/alignment/software/)  
- [agrep](http://manpages.ubuntu.com/manpages/bionic/man1/agrep.1.html)  
- An alignment editor software, such as [aliview](https://ormbunkar.se/aliview/) or [seaview](http://doua.prabi.fr/software/seaview)  
### In-house dependencies
- [sequenceSelect.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/sequenceSelect.py)  
- [alignmentConsensus.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/alignmentConsensus.py)  
- [multi2linefasta.py](https://github.com/MiguelMSandin/fasta-functions/blob/main/scripts/multi2linefasta.py)  
  
Download, move the scripts to you prefered folder (e.g.;`/usr/lobal/bin/`) and start running the pipeline. You might need to make the scripts executable as follows: `chmod +x script`.  
  
## Quick start  
If you already have a target fasta file and a reference fasta file (note that the reference file **should not** contain sequences associated to your targeted group), the **laziest option is simply running the wrapper `oligoNdesign`** as follows:  
  
`oligoNdesign -t target.fasta -r reference.fasta -o probes.fasta -l probes.tsv`  
  
And you will obtain a fasta file containing all candidate probes a log file with all the characteristics for each primer and a filtered fasta file and log file containing only the best scoring probes.  
  
However, if you want to have access to intermediate files you can **quickly run the pipeline** with default parameters as follows (explained in detail in the following section):   
  
`findPrimer -t target.fasta -r reference.fasta -o output`  
`testPrimer -r reference.fasta -f output.fasta -o output_tested.tsv`  
`alignPrimers -t target.fasta -p output.fasta -o target_primers.fasta`  
`rateAccess -f target_primers.fasta -o output_access.tsv`  
  
Briefly: First candidate primers are searched with `findPrimer`, then they are tested for unespecific hits with `testPrimer`. A consensus sequence is created from the target file and along with the candidate primers are aligned to the *Saccharomyces cerivisae* template  18S rDNA sequence with `alignPrimers` to estimate the accessibility with `rateAccess`. You can merge all log files as follows:  
  
`bindLogs -f probes.tsv output_tested.tsv output_access.tsv -o output_log.tsv`  
  
And based on your preferred parameters you select the best candidate primers/probes for preliminary laboratory experiments, as follows:  
  
`filterLog -l output_log.tsv -s 0.4 -m 0.001 -M 0.0001 -c III -v`  
  
  
## Overview
- **[1](https://github.com/MiguelMSandin/oligoN-design#1-prepare-files). Select a target and a reference fasta files**: containing the sequences of your group of inerest and a reference file with a complete overview of the diversity for the studied gene respectively (note that the target group should not be in the reference file).  
- **[2](https://github.com/MiguelMSandin/oligoN-design#2-find-specific-regions). Find candidate primers**: specific to your group of interest.  
- **[3](https://github.com/MiguelMSandin/oligoN-design#3-test-regions). Test candidate primers**: for possible mismatches against the reference database.  
- **[4](https://github.com/MiguelMSandin/oligoN-design#4-generate-a-consensus-sequence-of-the-target-file). Generate a consensus sequence of the group of interest**.   
- **[5](https://github.com/MiguelMSandin/oligoN-design#5-align-candidate-regions-to-consensus-sequences). Align candidate primers to the consensus sequence** to spot regions of interest.  
- **[6](https://github.com/MiguelMSandin/oligoN-design#6-estimate-the-secondary-structure). Estimate secondary structure of your target group**.  
- **[7](https://github.com/MiguelMSandin/oligoN-design#7-identify-best-accesibility-regions). Identify best accesibility regions**.  
- **[8](https://github.com/MiguelMSandin/oligoN-design#8-identification-of-the-best-candidate-primersprobes). Select the best candidate primers**.  
  
## Getting started with the detailed pipeline
First decide on which organism/group you want to be working with and your favourite reference file.  
In this example we are going to be using public data from the [PR2 database](https://pr2-database.org/), and focusing on the Diatom *Guinardia* as targeted group.  
Go to your working directory, download and unzip the PR2 database file:  
  
`wget https://github.com/pr2database/pr2database/releases/download/v4.14.0/pr2_version_4.14.0_SSU_taxo_long.fasta.gz`  
`gunzip -k pr2_version_4.14.0_SSU_taxo_long.fasta.gz`  
  
## 0. Prepare files
Now we are going to create the **target** and **reference** fasta files. To do so, we extract all sequences affiliated to *Guinardia* from the reference database and save them into the target file. We could do this with the script [sequenceSelect.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/sequenceSelect.py) as follows:  
  
`sequenceSelect.py -f pr2_version_4.14.0_SSU_taxo_long.fasta -o target.fasta -p Guinardia -a k -v`  
`sequenceSelect.py -f pr2_version_4.14.0_SSU_taxo_long.fasta -o reference.fasta -p Guinardia -a r -v`  
  
>**Note**: The target file might be created faster by using grep (`grep -A 1 Guinardia pr2_version_4.14.0_SSU_taxo_long.fasta > target.fasta`). Yet, the fasta file has to be saved with the sequences in one line, and not in several lines. You could use this [script](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/multi2linefasta.py) to change a multi-line fasta to single-line fasta if needed.  
  
## 1. Find candidate primers  
Once we have the target and reference files, we are going to search for specific regions of different lengths in the target file that are not present in the reference file. It is important to know that:  
- Not all sequences in a database are of the same length; and therefore the region of interest might not be present in all sequences from the target file.
- Despite enourmous and unvaluable efforts in manually curating reference databases, taxonomic annotation is not perfect. Therefore it is possible that the region of interest might also be present in the reference file due to chimeric sequences, badly annotated sequences or simply high similarity to other groups.  
  
With this in mind, we can search for specific regions using the script **[findPrimer](https://github.com/MiguelMSandin/oligoN-design/tree/main/scripts/findPrimer)** as follows:  
  
`findPrimer -t target.fasta -r reference.fasta -o guinardia_PR2_m80_s001 -l '18+22' -m 0.8 -s 0.001 -v`  
  
With this command we are looking for regions of 18, 19, 20, 21 and 22 base pairs (bp: `-l '18+22'`) that are present in at least 80% (`-m 0.8`) of the sequences in the target file (`-t target.fasta`) and at most 0.001% (`-s 0.001`) in the reference file (`-r reference.fasta`). In order to carry out different searches, we have included in the output file name key parameters of the search (`-o guinardia_PR2_m8_s001`). It will output two files: a fasta file containing all the primers that passed the search thresholds and a log file with parameters of the primer and the search in a [tsv](https://en.wikipedia.org/wiki/Tab-separated_values) file with the following columns:
- a sequence identifier,
- the length of the sequence,
- the sequence,
- the reverse complement of the sequence (if selected),
- the GC content (GC),
- the basic melting temperature (Tm),
- the proportion of hits in the target file,
- the absolute number of hits in the target file,
- the proportion of hits in the reference file,
- the absolute number of hits in the reference file.
  

| identifier |length | sequence | sequence_reverseComplement | GC | Tm | hits_target | hits_target_absolute | hits_reference | hits_reference_absolute |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| primer1 | 18 | CAAGTTTCTGCCCTATTA | TAATAGGGCAGAAACTTG | 0.3889 | 43.49 | 0.8157 | 31 | 0.0002 | 45 |
| primer2 | 20 | AATATGACACTGTCGGCATC | GATGCCGACAGTGTCATATT | 0.45 | 49.73 | 0.8421 | 32 | 0.00002 | 5 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
  
>**Note**: For further details on the usage of the script, use the help: `findPrimer -h`.  
  
**(TO BE IMPLEMENTED: Parallelization of the for loop and start the search in the target file and not the reference file)**  
  
## 2. Test candidate primers
Regions found in the previous step are now going to be tested for hits **allowing mismatches** against the same reference database using the script **[testPrimer](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/testPrimer)** as follows:  
  
`testPrimer -r reference.fidentifierasta -p guinardia_PR2_m8_s001.fasta -o guinardia_PR2_m8_s001_tested.tsv -v`  
  
Here we are using the fasta file generated in **step 1** and containing all potential primers/probes (`-p guinardia_PR2_m8_s001.fasta`) to search if it is present in the reference file (`-r reference.fasta`) allowing 1 and 2 mismatches. We save the output file with the option (`-o guinardia_PR2_m8_s001_tested.tsv`). This script will ouput a tsv file with the sequence identifier, the sequence itself and two columns for hits with 1 and 2 mismacth containing the proportion of hits and the absolute number of hits for the given mismatch, as in the following example:
  

| identifier | sequence | mismatch1 | mismatch1_abs | mismatch2 | mismatch2_abs |
| ----- | ----- | ----- | ----- | ----- | ----- |
| primer1 | CAAGTTTCTGCCCTATTA | 0.0509 | 9343 | 0.3855 | 70638 |
| primer2 | AATATGACACTGTCGGCATC | 0.00002 | 5 | 0.00002 | 5 |
| ... | ... | ... | ... | ... | ... |
  
If you are interested in further exploring the hits allowing mismatches of a specific primer/probe you could use the wrapper script [extractMismatches.sh](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/wrappers/extractMismatches.sh). This will export a fasta file containing all sequences that matched the specific primer/probe with the selected number of mismatches. And if you are very interested in exploring hits allowing more mismatches you can go fancy with the following script: [testPrimer.py](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/others/testPrimer.py), yet it's very slow at the moment.  
  
## 3. Estimate accessibility of the candidate primers
In this step, potential primers are going to be compared to the *Saccharomyces cerivisae* 18S rDNA sequence template to estimate the accessibility of the ribosomal region, based on [Behrens et al. (2003)](https://journals.asm.org/doi/10.1128/AEM.69.3.1748-1758.2003).  
To do so, we are going to create a consensus sequence of the target group, align it to the *S. cerivisae* 18S rDNA sequence template and then align the candidate primers to both sequences. We can do all of this with the wrapper script [alignPrimers](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/alignPrimers) (this script uses [mafft](https://mafft.cbrc.jp/alignment/software/)) as follows:  
  
`alignPrimers  -t target.fasta -p guinardia_PR2_m80_s001.fasta -o guinardia_PR2_m80_s001_probes_align.fasta`  
  
>**Note**:  The wrapper script will automatically generate two consensus sequences, one resolving ambiguities with the most abundant base and another keeping ambiguities. If you are interested in exploring the consensus options, have a look at the script [alignmentConsensus.py](https://github.com/MiguelMSandin/fasta-functions/blob/main/scripts/alignmentConsensus.py). You can even generate different consensus sequences to quickly explore big target files with the wraper [alignmentConsensus_compare.sh](https://github.com/MiguelMSandin/oligoN-design/tree/main/scripts/wrappers/alignmentConsensus_compare.sh).  
  
Now with this file, it is possible to estimate the accessibility of the candidate primers with the script 
  
`rateAccess -f guinardia_PR2_m80_s001_probes_align.fasta -o guinardia_PR2_m80_s001_access.tsv -v`  
  
This script will generate a log file with the following columns
- the sequence identifier,
- the sequence,
- the starting position of the primer/probe in the consensus sequence,
- the approximate region in the 18S rDNA,
- the starting position of the primer/probe in the *S. cerivisae* 18S rDNA sequence template,
- the average maximum brightness,
- the average minimum brightness,
- the average brightness,
- the estimated accessibility class (From 'I' to 'VI', understanding 'class I' as the most accessible).
  

| identifier | sequence | start_position | region | Scerevisae_start_position | average_max_brightness | average_min_brightness | average_brightness | class |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| tmp | tmp | tmp | tmp | tmp | tmp | tmp | tmp | tmp |
| tmp | tmp | tmp | tmp | tmp | tmp | tmp | tmp | tmp |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

## 4. Select the best candidate primers
  

## 5. Align candidate primers to consensus sequence(s)
With this step we want to know in what positions of the 18S rDNA gene the candidate regions are:  
  
`mafft --addfragments guinardia_PR2_m8_s001.fasta target_consensus.fasta > target_consensus_regions.fasta`
  
or **newly implemented**, if you want to also include the *Saccharomyces cerevisiae* template 18S sequence you can do it with the follwoing script (and if you have more than one sequence in the consensus file there is no need for previously align the file):  
  
`alignPrimers.sh -c target_consensus.fasta -p guinardia_PR2_m8_s001.fasta -o target_consensus_regions.fasta`

## 6. Estimate accessibility regions

`rateAccess.py -f target_consensus_regions.fasta -o guinardia_probes_access.tsv`  
  
## (TO BE DONE: 7 Add a script to automatically filter probes)
(Based on length, GC content, number of matches,...)
  
## (TO BE DONE: 7 Add a script to automatically select the X% best probes)


## 6. Estimate the secondary structure
### (to be implemented)
By using the recently develop tool [R2DT](https://github.com/rnacentral/R2DT) ([Sweeney et al., 2021](https://www.nature.com/articles/s41467-021-23555-5#citeas) ), it is possible to infer the secondary structure of (almost) any 18S rDNA.  
An easy example of using this tool can be uploading the consensus sequence created in **Step 3** to the [R2DT website](https://rnacentral.org/r2dt) an automatically generate the secondary structure of the rDNA by comparing to the best fitting profile.  
  
## 7. Identify best accesibility regions
### (to be implemented)
Little effort has been done in this area of research, yet Behrens et al. ([2003](https://journals.asm.org/doi/10.1128/AEM.69.3.1748-1758.2003)) provided an excellent map of probe accessibility for the eukaryotic 18S rDNA gene of *Saccharomyces cerevisiae*. Further, Bernier et al. ([2018](https://academic.oup.com/mbe/article/35/8/2065/5000151)) provided a 3D reconstruction of the rDNA operon and identified highly preserved and highly variable domains.  
  
## 8. Identification of the best candidate primers/probes
### (to be implemented)
By integrating the length, GC content, theoretical melting temperature and number of hits allowing mismatches obtained in this pipeline, along with the accesibility of the desire region, it is possible to **manually select the best candidate primers/probes** for your group. In this sense you want to select 2-4 primers/probes in order to **empirically test and cross-validate its specificity and functioning**, and therefore you will select candidate primers/probes:
- that covers most of the targeted diversity,  
- with a high GC content,  
- with similar theoretical melting temperature,  
- with low hits to the reference file allowing mismatches (or at least with hits to a known and morphologically distant group, i.e.; diatoms Vs copepods),  
- highly accessible,  
- and that avoids self-binding (**to be implemented**, i.e.; ACGTnnnnACGT).  
  
## Concluding remarks and further resources
Primer and probe design is a tedious work that requires a final empirical test for its completion. Therefore, bioinformatic pipelines will only provide theoretical candidate regions, that have to be tested in the laboratory. With this pipeline we attempted to generate an easy-to-use tool for the high-throughput design of primers/probes. However the [ARB](http://www.arb-home.de/) software from the [SILVA](https://www.arb-silva.de/) project is the choice of preference when studying a targeted group.  
It is also possible to [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&PAGE_TYPE=BlastSearch&LINK_LOC=blasthome) the desired primer/probe and test for the specificity in the most exhaustive databases. Or when using the 18S rDNA gene it is even possible to test for mismatches and taxonomic affiliation in the [PR2-primers](https://app.pr2-primers.org/) database.  
Other online resources (such as [oligoCalc](http://biotools.nubic.northwestern.edu/OligoCalc.html)) provide useful properties to start testing the primers/probe in the laboratory.  

## References
-Behrens S, Rühland C, Inácio J, Huber H, Fonseca A, Spencer-Martins I, Fuchs BM, Amann R. (2003) In situ accessibility of small-subunit rRNA of members of the domains Bacteria, Archaea, and Eucarya to Cy3-labeled oligonucleotide probes. Appl Environ Microbiol.69(3):1748-58. doi: [10.1128/AEM.69.3.1748-1758.2003](https://journals.asm.org/doi/10.1128/AEM.69.3.1748-1758.2003)  
-Bernier CR, Petrov AS, Kovacs NA, Penev PI, Williams LD. (2018) Translation: The Universal Structural Core of Life. Mol Biol Evol. 35(8):2065-2076. doi: [10.1093/molbev/msy101](https://academic.oup.com/mbe/article/35/8/2065/5000151)  
-Sweeney, B.A., Hoksza, D., Nawrocki, E.P. et al. (2021) R2DT is a framework for predicting and visualising RNA secondary structure using templates. Nat Commun 12, 3494. doi:[10.1038/s41467-021-23555-5](https://www.nature.com/articles/s41467-021-23555-5#citeas)  
  
  
