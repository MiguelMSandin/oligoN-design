#!/bin/bash

usage()
{
    echo ""
    echo "A simple wrapper to merge the log outputs from findPrimer.py and testPrimer.py. Please note that the two files must contain the primers in matching order of appearance, as it is output from the scripts."
    echo ""
    echo "  -h    Print this information"
    echo ""
    echo "  -f    The output of findPrimer.py"
    echo "  -t    The output of testPrimer.py"
    echo "  -o    The output."
    echo ""
}

while getopts "hf:t:o:" opt; do
        case ${opt} in
                h )
                        usage
                        exit
                        ;;
                f )
                        FIND=$OPTARG
                        ;;
                t )
                        TEST=$OPTARG
                        ;;
                o )
                        OUT=$OPTARG
                        ;;
        esac
done

tmp=$(mktemp --tmpdir=$(pwd))

awk '{$1=$2="";print}' tmp_log.tsv > $tmp

paste $FIND $tmp | column -s $'\t' -t > $OUT

sed -i 's/\s\+/\t/g' $OUT

rm -f $tmp
