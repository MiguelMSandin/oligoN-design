# oligoN-design (version v0.3.1-beta)
  
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10688602.svg)](https://doi.org/10.5281/zenodo.10688602)
  
The purpose of this pipeline is to produce oligonucleotide candidates for fluorescence *in situ* hybridisation (probes), yet primers for PCR amplification can also be searched. It focuses on the rDNA operon (specially the small subunit of the rDNA: 18S rDNA and 16S rDNA), but can potentially be used for other genes.  
  
Briefly, this pipeline takes a **target** [fasta](https://en.wikipedia.org/wiki/FASTA) file and searches for specific regions of the sequences against a **reference** fasta file. Later, based on the specificity, GC content, theoretical melting temperature and the accessibility of the selected region on the tertiary structure, the best probes are selected for empirical test in the laboratory.  
  
![brief_pipeline](/resources/bioinfo_pipeline_ppt.png)   
  
## Dependencies  
- [python](https://www.python.org/)  
    -   **Required modules**: argparse, Bio, sys, time, os, statistics, re, pandas.
    -   Optional modules: regex.  
- [mafft](https://mafft.cbrc.jp/alignment/software/)  
- [agrep](http://manpages.ubuntu.com/manpages/bionic/man1/agrep.1.html)  
- An alignment editor software, such as [aliview](https://ormbunkar.se/aliview/) or [seaview](http://doua.prabi.fr/software/seaview)  
### In-house dependencies
- [sequenceSelect.py](https://github.com/MiguelMSandin/random/blob/main/fasta/sequenceSelect.py)  
- [multi2linefasta.py](https://github.com/MiguelMSandin/random/blob/main/fasta/multi2linefasta.py)  
- [fastaRevCom.py](https://github.com/MiguelMSandin/random/blob/main/fasta/fastaRevCom.py)  
- [alignmentConsensus.py](https://github.com/MiguelMSandin/random/tree/main/fasta/alignmentConsensus.py)  
  
Download, move the scripts to you prefered folder (e.g.;`/usr/lobal/bin/`) and start running the pipeline. You might need to make the scripts executable as follows: `chmod +x script`.  
  
## Quick start  
If you already have a target fasta file and a reference fasta file (note that the reference file **should not** contain sequences associated to your targeted group), the **laziest option is simply running the wrapper `oligoNdesign`** as follows:  
  
```bash  
oligoNdesign -t target.fasta -r reference.fasta -o probes.fasta -l probes.tsv  
```  

Briefly, this script will:  
1) find all potential oligos with the script [findOligo](https://github.com/MiguelMSandin/oligoN-design/tree/main/scripts/findOligo),
2) test all potential oligos for hits allowing 1 and 2 mismatches with the script [testOligo](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/testOligo),
3) align the selected template (where an accessibility map has been empirically tested) to the consensus of the target file and the oligos with the script [alignOligo](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/alignOligo),
4) rate the accessibility of all oligos with the script [rateAccess](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/rateAccess),
5) bind all different log files with the script [bindLogs](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/bindLogs),
6) filter the oligos to obtain only the highest quality statistics with the script [filterLog](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/filterLog).
 
And you will obtain a fasta file containing all candidate probes a log file with all the characteristics for each probe and a filtered fasta file and log file containing only the best scoring probes.  
   
## Getting started with the detailed pipeline
First decide on which organism/group you want to be working with and your favourite reference file.  
In this example we are going to be using public data from the [PR2 database](https://pr2-database.org/), and focusing on the Diatom *Guinardia* as targeted group.  
Go to your working directory, download and unzip the PR2 database file:  
  
```bash  
wget https://github.com/pr2database/pr2database/releases/download/v5.0.0/pr2_version_5.0.0_SSU_taxo_long.fasta.gz  
gunzip pr2_version_5.0.0_SSU_taxo_long.fasta.gz  
```  
  
## 0. Prepare files
Now we are going to create the **target** and **reference** fasta files. To do so, we extract all sequences affiliated to *Guinardia* from the reference database and save them into the target file. We could do this with the script [sequenceSelect.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/sequenceSelect.py) as follows:  
  
```bash  
sequenceSelect.py -f pr2_version_5.0.0_SSU_taxo_long.fasta -o target.fasta -p Guinardia -a k -v  
sequenceSelect.py -f pr2_version_5.0.0_SSU_taxo_long.fasta -o reference.fasta -p Guinardia -a r -v  
```  
  
>**Note**: The target file might be created faster by using grep (`grep -A 1 Guinardia pr2_version_4.14.0_SSU_taxo_long.fasta > target.fasta`). Yet, the fasta file has to be saved with the sequences in one line, and not in several lines. You could use this [script](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/multi2linefasta.py) to change a multi-line fasta to single-line fasta if needed.  
  
## 1. Find candidate probes  
Once we have the target and reference files, we are going to search for specific regions of different lengths in the target file that are not present in the reference file. It is important to know that:  
- Not all sequences in a database are of the same length; and therefore the region of interest might not be present in all sequences from the target file.
- Despite enourmous and unvaluable efforts in manually curating reference databases, taxonomic annotation is not perfect. Therefore, it is possible that the region of interest might also be present in the reference file due to chimeric sequences, badly annotated sequences or simply high similarity to other groups.  
  
With this in mind, we can search for specific regions using the script [findOligo](https://github.com/MiguelMSandin/oligoN-design/tree/main/scripts/findOligo). Here is an example how to run it:  
  
```bash  
findOligo -t target.fasta -r reference.fasta -o probes -l '18-22' -m 0.8 -s 0.001  
```  
  
With this command, we are looking for regions of 18, 19, 20, 21 and 22 base pairs (bp: `-l '18-22'`) that are present in at least 80% (`-m 0.8`) of the sequences in the target file (`-t target.fasta`) and at most 0.001% (`-s 0.001`) in the reference file (`-r reference.fasta`) and we simply save the output with the prefix "probes" (`-o probes`). This command will output two files: (1) a fasta file containing all the probes that passed the search thresholds and (2) a log file with parameters of the probe and the search in a [tsv](https://en.wikipedia.org/wiki/Tab-separated_values) file with the following columns:
- a sequence identifier,
- the length of the sequence,
- the sequence,
- the reverse complement of the sequence,
- the GC content (GC),
- the basic melting temperature (Tm),
- the proportion of hits in the target file,
- the absolute number of hits in the target file,
- the proportion of hits in the reference file,
- the absolute number of hits in the reference file.
  

| id |length | sequence | revCom | GC | Tm | hitsT | hitsT_abs | hitsR | hitsR_abs |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| oligoN1 | 18 | CAAGTTTCTGCCCTATTA | TAATAGGGCAGAAACTTG | 0.3889 | 43.49 | 0.8157 | 31 | 0.0002 | 45 |
| oligoN2 | 20 | AATATGACACTGTCGGCATC | GATGCCGACAGTGTCATATT | 0.45 | 49.73 | 0.8421 | 32 | 0.00002 | 5 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
  
>**Note**: For further details on the usage of the script, use the help: `findOligo -h`.  
  
Sequences in the output fasta file are given in the input sense, most commonly 5'-3'. It is possible to quickly reverse complement the file with the script [fastaRevCom.py](https://github.com/MiguelMSandin/fasta-functions/blob/main/scripts/fastaRevCom.py) as follows: `fastaRevCom.py -f probes.fasta -o probes_revCom.fasta`.  
  
**(TO BE IMPLEMENTED: Parallelization/multithreading of the for loop)**  
  
## 2. Test candidate probes
Regions found in the previous step are now going to be tested for hits **allowing mismatches** against the same reference database using the script [testOligo](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/testOligo) (this script uses [agrep](http://manpages.ubuntu.com/manpages/bionic/man1/agrep.1.html)) as follows:  
  
```bash  
testOligo -r reference.fasta -p probes.fasta -o probes_tested.tsv  
```  
  
Here we are using the fasta file generated in **step 1** and containing all potential probes (`-p probes.fasta`) to search if it is present in the reference file (`-r reference.fasta`) allowing 1 and 2 mismatches, and with the option `-o` we save the output (`-o probes_tested.tsv`). This script will ouput a tsv file with the sequence identifier, the sequence itself and two columns for hits with 1 and 2 mismacth containing the proportion of hits and the absolute number of hits for the given mismatch, as in the following example:  
  

| identifier | sequence | mismatch1 | mismatch1_abs | mismatch2 | mismatch2_abs |
| ----- | ----- | ----- | ----- | ----- | ----- |
| oligoN1 | CAAGTTTCTGCCCTATTA | 0.0509 | 9343 | 0.3855 | 70638 |
| oligoN2 | AATATGACACTGTCGGCATC | 0.00002 | 5 | 0.00002 | 5 |
| ... | ... | ... | ... | ... | ... |
  
If you are interested in further exploring the hits allowing mismatches of a specific probe you could use the wrapper script [extractMismatches.sh](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/wrappers/extractMismatches.sh). This will export a fasta file containing all sequences that matched the specific probe with the selected number of mismatches. And if you are very interested in exploring hits allowing more mismatches you can go fancy with the following script: [testOligo.py](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/others/testOligo.py), yet it's very slow at the moment.  
  
## 3. Estimate accessibility of the candidate probes
(If you had already selected your probes, you can still analyse them following the logic from **Step 1** and **Step 2** with the script [assessOligo](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/assessOligo).)  
  
In this step, potential probes are going to be compared to the *Saccharomyces cerivisae* 18S rDNA sequence template to estimate the accessibility of the ribosomal region, based on [Behrens et al. (2003)](https://journals.asm.org/doi/10.1128/AEM.69.3.1748-1758.2003).  
To do so, we are going to create a consensus sequence of the target group, align it to the *S. cerivisae* 18S rDNA sequence template and then align the candidate probes to the reference alignment. We can do all of this with the wrapper script [alignOligo](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/alignOligo) (this script uses [mafft](https://mafft.cbrc.jp/alignment/software/) and [alignmentConsensus.py](https://github.com/MiguelMSandin/fasta-functions/tree/main/scripts/alignmentConsensus.py)) as follows:  
  
```bash  
alignOligo -t target.fasta -p probes.fasta -o probes_align.fasta  
```  
  
This script will generate an aligned fasta file with the *S. cerivisae* 18S rDNA sequence template, a consensus sequence of the target file resolving ambiguities with the most abundant base, a consensus sequence of the target file (with a consensus threshold of 70%, a base detection threshold of 30% and a gap threshold of 80%) and all the candidate probes.  
  
> If you are interested in exploring the consensus options, have a look at the script [alignmentConsensus.py](https://github.com/MiguelMSandin/fasta-functions/blob/main/scripts/alignmentConsensus.py). You can even generate different consensus sequences to quickly explore big target files with the wraper [alignmentConsensus_compare.sh](https://github.com/MiguelMSandin/oligoN-design/tree/main/scripts/wrappers/alignmentConsensus_compare.sh).  
  
Now with this file, it is possible to **estimate the accessibility of the candidate probes** with the script [rateAccess](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/rateAccess) as follows:  
  
```bash  
rateAccess -f probes_align.fasta -o probes_access.tsv  
```  
  
This script will generate a log file with the following columns
- the sequence identifier,
- the sequence,
- the starting position of the probe in the consensus sequence,
- the approximate region in the 18S rDNA (from V1 to V9 and flanking them from C1 to C10),
- the starting position of the probe in the *S. cerivisae* 18S rDNA sequence template,
- the average maximum brightness,
- the average minimum brightness,
- the average brightness,
- the estimated accessibility class (From 'I' to 'VI', understanding 'class I' as the most accessible).
  

| identifier | sequence | start_position | region | Scerevisae_start_position | average_max_brightness | average_min_brightness | average_brightness | class |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| oligoN1 | CAAGTTTCTGCCCTATTA | 276 | C3 | 298 | 0.67 | 0.48 | 0.57 | III |
| oligoN2 | AATATGACACTGTCGGCATC | 1039 | V5 | 1056 | 0.52 | 0.34 | 0.43 | III |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |
  

## 4. Select the best candidate probes
To ease identification of the best candidate probes, we can now **merge all the different log files** obtained through this pipeline into one single log file with the script [bindLogs](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/bindLogs) as follows:  
  
```bash
bindLogs -f probes.tsv probes_tested.tsv probes_access.tsv -o probes_log.tsv -r  
```  
  
> **Note**: Since we are merging the threee different log files into one, we can remove the individual files adding the option `-r`.  
  
By integrating the length, GC content, theoretical melting temperature and number of hits allowing mismatches and the accesibility of the desire region, it is possible to **manually select the best candidate probes** for your group. In this sense you want to select 2-4 probes:
- that cover most of the targeted diversity,  
- have a high GC content,  
- have similar theoretical melting temperature,  
- show low number of hits in the reference file allowing mismatches (or at least with hits to a known and morphologically distant group, i.e.; diatoms Vs copepods),  
- traget highly accessible sites.    
  
It is also possible to **automatically filter** the log file and select all probes that matches several criteria with the script [filterLog](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/filterLog), for example we could be interested in probes with:  
- GC content equal or higher than 40%,
- with less than 0.001% hits against the reference file allowing 2 mismatch,
- and with an average accesibility brightness of 0.4.  
  
To do so we run the following command:  

```bash  
filterLog -l probes_log.tsv -s "0.4" -M "0.0001" -b "0.4"  
```  
  
Finally, we can select (for example) the best 4 probes based on the number of hits allowing mismatches with the script [selectLog](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/selectLog), as follows:  

```bash  
selectLog -l probes_log_filtered.tsv -N "4"  
```  
  
It is important to understand that any bioinformatic work only provides theoretical values and information. Therefore it is mandatory to **empirically test and cross-validate the specificity and functioning of each probe** for the final decission.  
  
**(TO BE IMPLEMENTED: Add a function to test for self-binding (i.e.; ACGTnnnnACG))**  
  
## (TO BE IMPLEMENTED: 5. Estimate the secondary structure)
By using the recently develop tool [R2DT](https://github.com/rnacentral/R2DT) ([Sweeney et al., 2021](https://www.nature.com/articles/s41467-021-23555-5#citeas) ), it is possible to infer the secondary structure of (almost) any 18S rDNA.  
An easy example of using this tool can be uploading the consensus sequence created in **Step 3** to the [R2DT website](https://rnacentral.org/r2dt) an automatically generate the secondary structure of the rDNA by comparing to the best fitting profile.  
  
## Replicable summary of the detailed pipeline
Briefly, let's assume we call the target file **target.fasta**, the reference file **reference.fasta** and the output beginning with **probes**, we can run the pipeline as follows:  

```bash  
TARGET="target.fasta"  
REFERENCE="reference.fasta"  
OUTPUT="probes"  
  
findOligo -t $TARGET -r $REFERENCE -o $OUTPUT -l '18-22' -m 0.8 -s 0.001  
testOligo -r $REFERENCE -p "$OUTPUT.fasta" -o $OUTPUT"_tested.tsv"  
alignOligo -t $TARGET -p "$OUTPUT.fasta" -o $OUTPUT"_align.fasta"  
rateAccess -f $OUTPUT"_align.fasta" -o $OUTPUT"_access.tsv"  
bindLogs -f "$OUTPUT.tsv" $OUTPUT"_tested.tsv" $OUTPUT"_access.tsv" -o $OUTPUT"_log.tsv" -r  
filterLog -l $OUTPUT"_log.tsv" -s "0.4" -M "0.001" -b "0.4"  
```  
  
At the end there are 4 different files:
- probes.fasta: A fasta file with all the probes in the input sense (most commonly 5'-3').  
- probes_align.fasta: Contains an alignment of the *S. cerivisae* 18S rDNA sequence template, a consensus sequence of the target file resolving ambiguities with the most abundant base, a consensus sequence of the target file and all the candidate probes.  
- probes_log.tsv: A tsv file with all the information for each probe.  
- probes_log_filtered.fasta: The previous log file filtered with probes that match all the selected criteria.  
  
Remember, that it is possible to quickly reverse complement the fasta file containing the probes as follows:  
```bash
fastaRevCom.py -f $OUTPUT.fasta -o $OUTPUT"_revCom.fasta"  
```  
  
You can find this script commented in [pipeline.sh](https://github.com/MiguelMSandin/oligoN-design/blob/main/scripts/pipeline.sh).  
  
## Concluding remarks and further resources
Probe design is a tedious work that requires a final empirical test for its completion. Therefore, bioinformatic pipelines will only provide theoretical candidate regions, that have to be tested in the laboratory. With this pipeline, we attempted to generate an easy-to-use tool for the high-throughput design of probes. However the [ARB](http://www.arb-home.de/) software from the [SILVA](https://www.arb-silva.de/) project is the choice of preference when studying a targeted and well documented group. It is also worth trying the [DECIPHER](http://www2.decipher.codes/OligoDesign.html) package from [R](https://www.r-project.org/).  
It is also possible to [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&PAGE_TYPE=BlastSearch&LINK_LOC=blasthome) the desired oligonucleotide and test for the specificity in the most exhaustive databases. Or when using the 18S rDNA gene it is even possible to test for mismatches and taxonomic affiliation in the [PR2-primers](https://app.pr2-primers.org/) database.  
Other online resources (such as [oligoCalc](http://biotools.nubic.northwestern.edu/OligoCalc.html)) provide useful properties to start testing the oligonucleotide in the laboratory.  
  
## References
-Behrens S, Rühland C, Inácio J, Huber H, Fonseca A, Spencer-Martins I, Fuchs BM, Amann R. (2003) In situ accessibility of small-subunit rRNA of members of the domains Bacteria, Archaea, and Eucarya to Cy3-labeled oligonucleotide probes. Appl Environ Microbiol.69(3):1748-58. doi: [10.1128/AEM.69.3.1748-1758.2003](https://journals.asm.org/doi/10.1128/AEM.69.3.1748-1758.2003)   
-Sweeney, B.A., Hoksza, D., Nawrocki, E.P. et al. (2021) R2DT is a framework for predicting and visualising RNA secondary structure using templates. Nat Commun 12, 3494. doi:[10.1038/s41467-021-23555-5](https://www.nature.com/articles/s41467-021-23555-5#citeas)  
  
  
