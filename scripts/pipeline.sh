#!/bin/bash

TARGET=".fasta"
REFERENCE=".fasta"

PROBES=""
OUTPUT=""
CONSENSUS=".fasta"

# First find candidate regions
findPrimer.py -t $TARGET -r $REFERENCE -o $PROBES

# Test the candidate regions
testPrimer.py -r $REFERENCE -f $PROBES.fasta -o $PROBES"_TP.tsv"

# Bind the outputs
bindFindTest.sh -f $PROBES.tsv -t $PROBES"_TP.tsv" -o $OUTPUT

# Add here scripts to automatically select probes
##

# Align target file
mafft $TARGET > ${TARGET/.fasta/_align.fasta} # Change extension if needed
alignmentConsensus.py -f ${TARGET/.fasta/_align.fasta} -o $CONSENSUS -m
alignmentConsensus.py -f ${TARGET/.fasta/_align.fasta} -o $CONSENSUS

# Align the consensus sequence to the Saccharomyces cerevisiae template and the align the probes
alignPrimers.sh -c $CONSENSUS -p $PROBES.fasta -o ${CONSENSUS/.fasta/_probes.fasta}

# Estimate accessibility by the relative position to the S. cerevisiae template
rateAccess.py -f ${CONSENSUS/.fasta/_probes.fasta} -o $PROBES"_access.tsv"


