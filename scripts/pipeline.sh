#!/bin/bash

TARGET=""
REFERENCE=""
OUTPUT=""

# Create TARGET and REFERENCE files from a single file and convert to single line fasta files ------
# FILE="" # The file containing both the target group and the reference sequences
# GROUP="" # The pattern matching the target group for selecting sequences
# 
# sequenceSelect.py -f $FILE -o tmp -p $GROUP -a k
# multi2linefasta.py -f tmp -o $TARGET
# sequenceSelect.py -f $FILE -o tmp -p $GROUP -a r
# multi2linefasta.py -f tmp -o $REFERENCE
# rm -f tmp

# First find candidate regions ---------------------------------------------------------------------
findOligo -t $TARGET -r $REFERENCE -o $OUTPUT -l '18-22' -m "0.8" -s "0.001"

# Test the candidate regions -----------------------------------------------------------------------
testOligo -r $REFERENCE -p "$OUTPUT.fasta" -o $OUTPUT"_tested.tsv"

# Rate access of the candidate regions -------------------------------------------------------------
alignOligo -t $TARGET -p "$OUTPUT.fasta" -o $OUTPUT"_align.fasta"
rateAccess -f $OUTPUT"_align.fasta" -o $OUTPUT"_access.tsv"

# Bind all log files -------------------------------------------------------------------------------
bindLogs -f "$OUTPUT.tsv" $OUTPUT"_tested.tsv" $OUTPUT"_access.tsv" -o $OUTPUT"_log.tsv" -r

# Filter the log files -----------------------------------------------------------------------------
filterLog -l $OUTPUT"_log.tsv" -s "0.4" -M "0.001" -b "0.4"
selectLog -l $OUTPUT"_log_filtered.tsv" -N 4

