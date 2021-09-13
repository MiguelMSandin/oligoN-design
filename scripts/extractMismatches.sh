#!/bin/bash

usage()
{
    echo ""
    echo "A wrapper to find hits of a primer/probe in a reference database allowing mismatches and returning a fasta file."
    echo "Uses 'agrep' to search allowing mismatches."
    echo ""
    echo "Usage: agrep2fasta.sh -m mismatches -p pattern -f file -o outFile"
    echo ""
    echo "  -h    Print this information"
    echo ""
    echo "  -m    The number of mismatches allowed"
    echo "  -p    The pattern to be seach"
    echo "  -f    The file to search the pattern in"
    echo "  -o    The output file name"
    echo ""
    echo "For further information use 'agrep --help'"
    echo ""
    echo "Note that for '-m 0' might be faster to simply use grep as follows: 'grep -B 1 pattern file > outFile'"
    echo ""
}

while getopts "hm:p:f:o:" opt; do
        case ${opt} in
                h )
                        usage
                        exit
                        ;;
                m )
                        MISMATCH=$OPTARG
                        ;;
                p )
                        PATTERN=$OPTARG
                        ;;
                f )
                        FILE=$OPTARG
                        ;;
                o )
                        OUT=$OPTARG
                        ;;
        esac
done

tmp1=$(mktemp --tmpdir=$(pwd))
tmp2=$(mktemp --tmpdir=$(pwd))

echo "  Searching"
agrep -$MISMATCH "$PATTERN" $FILE > $tmp1

echo "    There are $(wc -l $tmp1 | cut -d " " -f 1) total hits"

echo "  Extracting headers"
LINES=$(cat $tmp1)
for LINE in $LINES
do
	grep -B 1 $LINE $FILE >> $tmp2
done

echo "  Removing duplicates"
awk '/^>/{f=!d[$1];d[$1]=1}f' $tmp2 >> $OUT

rm -f $tmp1 $tmp2

echo "Done"
