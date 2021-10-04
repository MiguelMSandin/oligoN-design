#!/bin/bash

usage()
{
    echo ""
    echo "A wrapper to automatically select the best candidate regions from a target and a reference file."
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

OUT_FASTA_NOEXT=$(echo $OUT_FASTA | rev | cut -f 2- -d '.' | rev)
EXT="${OUT_FASTA##*.}"

# Search for candidate primers
echo "Searching candidate primers"
findPrimer.py -t $TARGET -r $REFERENCE -o $OUT_FASTA_NOEXT -v

if [ "$OUT_FASTA_NOEXT.fasta" != "$OUT_FASTA" ]; then
	mv "$OUT_FASTA_NOEXT.fasta" $OUT_FASTA
fi

if [ "$OUT_FASTA_NOEXT.tsv" == "$OUT_LOG" ]; then
	mv "$OUT_FASTA_NOEXT.tsv" "$OUT_FASTA_NOEXT.2.tsv"
fi

# test the candidate primers
echo "Testing candidate primers"
tmp1=$(mktemp --tmpdir=$(pwd))
testPrimer.py -r $REFERENCE -f $OUT_FASTA -o $tmp1 -v

# Create a consensus sequence from the target file
echo "Creating a consensus sequence from the target file"
tmp2=$(mktemp --tmpdir=$(pwd))
createConsensus.sh -t $TARGET -o $tmp2

# align primers and consensus sequence to Saccharomyces cerivisae template 18S rDNA sequence
echo "Aligning primers to the consensus sequence and the Saccharomyces cerivisae template 18S rDNA sequence"
tmp3=$(mktemp --tmpdir=$(pwd))
alignPrimers.sh -c $tmp2 -p $OUT_FASTA -o $tmp3

# Estimate accessibility of the primers
echo "Estimating accessibility of the primers"
tmp4=$(mktemp --tmpdir=$(pwd))
rateAccess.py -f $tmp3 -o $tmp4 -v

# Bind all log files into a single log file
echo "Merging log files to $OUT_LOG"

if [ "$OUT_FASTA_NOEXT.tsv" == "$OUT_LOG" ]; then
	bindLogs.py -f "$OUT_FASTA_NOEXT.2.tsv" "$tmp1" "$tmp4" -o "$OUT_LOG" -v -r
else
	bindLogs.py -f "$OUT_FASTA_NOEXT.tsv" "$tmp1" "$tmp4" -o "$OUT_LOG" -v -r
fi

# Filtering primers
echo "Filtering primers"
filterPrimer.py -l "$OUT_LOG" -s "0.4" -m "0.0001" -M "0.0001" -c "III" -v

# And remove temporary files
rm -f $tmp1 $tmp2 $tmp3 $tmp4 "$OUT_FASTA_NOEXT.tsv"

echo ""
echo "Final fasta file containing all primers/probes exported to: $OUT_FASTA"
echo "Final log file containing all primers/probes information exported to: $OUT_LOG"
echo "Filtered log file containing best primers/probes exported to: $(echo $OUT_LOG | rev | cut -f 2- -d '.' | rev)_filtered.tsv"
echo ""

echo "Finished"
