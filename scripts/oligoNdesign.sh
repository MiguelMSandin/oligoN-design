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

echo ""

# test the candidate primers
echo "Testing candidate primers"
tmp1=$(mktemp --tmpdir=$(pwd))
testPrimer.py -r $REFERENCE -f $OUT_FASTA -o $tmp1 -v

echo ""

# align primers and consensus sequence to Saccharomyces cerivisae template 18S rDNA sequence
echo "Aligning primers to the consensus sequence and the Saccharomyces cerivisae template 18S rDNA sequence"
tmp2=$(mktemp --tmpdir=$(pwd))
alignPrimers.sh -t $TARGET -p $OUT_FASTA -o $tmp2

echo ""

# Estimate accessibility of the primers
echo "Estimating accessibility of the primers"
tmp3=$(mktemp --tmpdir=$(pwd))
rateAccess.py -f $tmp2 -o $tmp3 -v

echo ""

# Bind all log files into a single log file
echo "Merging log files to $OUT_LOG"

if [ "$OUT_FASTA_NOEXT.tsv" == "$OUT_LOG" ]; then
	bindLogs.py -f "$OUT_FASTA_NOEXT.2.tsv" "$tmp1" "$tmp3" -o "$OUT_LOG" -v -r
else
	bindLogs.py -f "$OUT_FASTA_NOEXT.tsv" "$tmp1" "$tmp3" -o "$OUT_LOG" -v -r
fi

echo ""

# Filtering primers
echo "Filtering primers"
filterPrimer.py -l "$OUT_LOG" -s "0.4" -m "0.0001" -M "0.001" -c "III" -f $OUT_FASTA -v

echo ""

# And remove temporary files
rm -f $tmp1 $tmp2 $tmp3

echo ""
echo "Final fasta file containing all probes exported to: $OUT_FASTA"
echo "Final log file containing all probes information exported to: $OUT_LOG"
echo "Filtered fasta file containing best probes exported to: $(echo $OUT_FASTA | rev | cut -f 2- -d '.' | rev)_filtered.fasta"
echo "Filtered log file containing best probes exported to: $(echo $OUT_LOG | rev | cut -f 2- -d '.' | rev)_filtered.tsv"
echo ""

echo "Finished"
