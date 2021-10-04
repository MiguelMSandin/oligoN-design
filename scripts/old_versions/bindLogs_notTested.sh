#!/bin/bash

usage()
{
    echo ""
    echo "A simple wrapper to merge the log outputs from findPrimer.py, testPrimer.py and rateAccess.py. Please note that all files must contain the primers in matching order of appearance, as it is output from the scripts."
    echo ""
    echo "Usage: bindLogs.sh -f FIND -t TEST -a ACCESS -o OUTPUT"
    echo ""
    echo "  -h    Print this information"
    echo ""
    echo "  -f    The output of findPrimer.py"
    echo "  -t    The output of testPrimer.py"
    echo "  -a    The output of rateAccess.py"
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
                a )
                        ACESS=$OPTARG
                        ;;
                o )
                        OUT=$OPTARG
                        ;;
        esac
done

tmp1=$(mktemp --tmpdir=$(pwd))
tmp2=$(mktemp --tmpdir=$(pwd))

awk '{$1=$2="";print}' $TEST > $tmp1
awk '{$1=$2="";print}' $ACCESS > $tmp1

paste $FIND $tmp1 $tmp2 | column -s $'\t' -t > $OUT

sed -i 's/\s\+/\t/g' $OUT

rm -f $tmp1 $tmp2
