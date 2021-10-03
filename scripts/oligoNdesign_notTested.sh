#!/bin/bash

usage()
{
    echo ""
    echo "A wrapper to automatically select candidate regions from a target and a reference file."
    echo ""
    echo "Usage: oligoNdesign.sh -t TARGET -r REFERENCE -o outputFasta -l outputLog"
    echo ""
    echo "  -h    Print this information"
    echo ""
    echo "  -t    The fasta file containing the target group."
    echo "  -r    The fasta file containing the reference group."
    echo "  -o    The output fasta file containing the primers."
    echo "  -l    The output logfile name containing the information."
    echo "This wrapper uses MAFFT: https://mafft.cbrc.jp/alignment/software/"
    echo ""
    echo "Please cite:"
    echo "Katoh, Misawa, Kuma, Miyata (2002) MAFFT: a novel method for rapid multiple sequence alignment based on fast Fourier transform. Nucleic Acids Res. 30:3059-3066"
    echo ""
}

while getopts "ht:r:o:l:" opt; do
        case ${opt} in
                h )
                        usage
                        exit
                        ;;
                t )
                        TARGET=$OPTARG
                        ;;
                r )
                        REFERENCE=$OPTARG
                        ;;
                o )
                        OUT_FASTA=$OPTARG
                        ;;
                l )
                        OUT_LOG=$OPTARG
                        ;;
        esac
done

# Create temporary files and variables
tmp1=$(mktemp --tmpdir=$(pwd))
tmp2=$(mktemp --tmpdir=$(pwd))
tmp3=$(mktemp --tmpdir=$(pwd))
tmp4=$(mktemp --tmpdir=$(pwd))
tmp5=$(mktemp --tmpdir=$(pwd))

OUT_FASTA_NOEXT=$(echo $OUT_FASTA | rev | cut -f 2- -d '.' | rev)
EXT="${OUT_FASTA##*.}"

# Search for candidate primers
findPrimer.py -t $TARGET -r $REFERENCE -o $OUT_FASTA_NOEXT
mv "$OUT_FASTA_NOEXT.fasta" $OUT_FASTA

# test the candidate primers
testPrimer.py -r $REFERENCE -f $OUT_FASTA -o $tmp2

# Create a consensus sequence from the target file
createConsensus.sh -t $TARGET -o $tmp3

# align primers and consensus sequence to Saccharomyces cerivisae template 18S rDNA sequence
alignPrimers.sh -c $tmp3 -p $OUT_FASTA -o $tmp4

# Estimate accessibility of the primers
rateAccess.py -f $tmp4 -o $tmp5

# Bind all log files into a single log file
bindLogs.sh -f "$OUT_FASTA_NOEXT.tsv" -t $tmp3 -a $tmp5 -o $OUT_LOG

# And remove temporary files
rm -f $tmp1 $tmp2 $tmp3 $tmp4 $tmp5 "$OUT_FASTA_NOEXT.tsv"

echo "Done"

