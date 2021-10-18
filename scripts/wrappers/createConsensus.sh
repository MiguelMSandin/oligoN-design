#!/bin/bash

usage()
{
    echo ""
    echo "A wrapper to create consensus sequences of an unaligned fasta file"
    echo ""
    echo "Usage: alignPrimers.sh -t TARGET -o outFile"
    echo ""
    echo "  -h    Print this information"
    echo ""
    echo "  -t    The fasta file containing the target group."
    echo "  -o    The output file name."
    echo "This wrapper uses MAFFT: https://mafft.cbrc.jp/alignment/software/"
    echo ""
    echo "Please cite:"
    echo "Katoh, Misawa, Kuma, Miyata (2002) MAFFT: a novel method for rapid multiple sequence alignment based on fast Fourier transform. Nucleic Acids Res. 30:3059-3066"
    echo ""
}

while getopts "ht:o:" opt; do
        case ${opt} in
                h )
                        usage
                        exit
                        ;;
                t )
                        TARGET=$OPTARG
                        ;;
                o )
                        OUT=$OPTARG
                        ;;
        esac
done

# Create temporary files
tmp1=$(mktemp --tmpdir=$(pwd))


# Align target file
echo "  Aligning sequences"
mafft --quiet $TARGET > $tmp1

# Create consensus sequences using the most abundant base to resolve ambiguous positions
echo "  Generating consensus sequence with the most abundant base"
alignmentConsensus.py -f $tmp1 -o $OUT -r -m
# Create consensus sequences allowing ambiguous positions
echo "  Generating consensus sequence allowing ambiguities"
alignmentConsensus.py -f $tmp1 -o $OUT -r

# And removing temporary files
rm -f $tmp1

echo "Done"

