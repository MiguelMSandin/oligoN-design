#!/bin/bash

# The name of the alignment file
FILE=""
# The name of the output file (the following line replace '_align.fasta' with '_consensus.fasta')
OUTPUT=${FILE/_align.fasta/_consensus.fasta}

# And now copy, paste and modify as many times as different parameters you want to epxlore. For example:
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
