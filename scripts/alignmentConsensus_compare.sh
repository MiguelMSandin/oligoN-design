#!/bin/bash

FILE="pr2_version_4.14.0_SSU_taxo_long_bacillariophyta_align.fasta"
OUTPUT=${FILE/_align.fasta/_consensus.fasta}

echo "Building consensus with most abundant base as consensus"
/shared/projects/radecoevo/probes/scripts/alignmentConsensus.py -f $FILE -o $OUTPUT -r -v -m
echo "--------------------"

echo "Building consensus with default parameters (-t 70 -b 30 -g 80)"
/shared/projects/radecoevo/probes/scripts/alignmentConsensus.py -f $FILE -o $OUTPUT -r -v
echo "--------------------"

echo "Building consensus with the following parameters: -t 70 -b 30 -g 50"
/shared/projects/radecoevo/probes/scripts/alignmentConsensus.py -f $FILE -o $OUTPUT -r -v -t 70 -b 30 -g 50
echo "--------------------"

echo "Building consensus with the following parameters: -t 80 -b 20 -g 80"
/shared/projects/radecoevo/probes/scripts/alignmentConsensus.py -f $FILE -o $OUTPUT -r -v -t 80 -b 20 -g 80
echo "--------------------"

echo "Building consensus with the following parameters: -t 90 -b 10 -g 80"
/shared/projects/radecoevo/probes/scripts/alignmentConsensus.py -f $FILE -o $OUTPUT -r -v -t 90 -b 10 -g 80
echo "--------------------"

echo "Building consensus with the following parameters: -t 95 -b 05 -g 80"
/shared/projects/radecoevo/probes/scripts/alignmentConsensus.py -f $FILE -o $OUTPUT -r -v -t 95 -b 05 -g 80
echo "--------------------"

echo ""
echo "Done"
