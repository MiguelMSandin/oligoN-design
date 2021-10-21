#!/bin/bash

usage()
{
    echo ""
    echo "A wrapper to quickly test primers against a reference database allowing 1 and 2 mismatches."
    echo ""
    echo "Usage: testPrimers.sh -p PRIMERS -r REFERENCE -o OUTPUT"
    echo ""
    echo "  -h    Print this information"
    echo ""
    echo "  -p    Primers/probes fasta file."
    echo "  -r    Reference fasta file."
    echo "  -o    Output log file."
    echo ""
    echo "This script uses 'agrep'"
}

while getopts "hp:r:o:" opt; do
        case ${opt} in
                h )
                        usage
                        exit
                        ;;
                p )
                        PRIMERS=$OPTARG
                        ;;
                r )
                        REFERENCE=$OPTARG
                        ;;
                o )
                        OUT=$OPTARG
                        ;;
        esac
done

PRIMERSSEQS=$(grep -c ">" $PRIMERS)
echo "  Primers file:        $PRIMERS"
echo "  Number of sequences: $PRIMERSSEQS"

REFSEQS=$(grep -c ">" $REFERENCE)
echo "  Reference file:      $REFERENCE"
echo "  Number of sequences: $REFSEQS"

echo "  Searching..."
echo -e "identifier\tsequence\tmismatch1\tmismatch1_abs\tmismatch2\tmismatch2_abs" > $OUT

i=0
while read LINE; do
	EXPORT="FALSE"
	if echo $LINE | grep -q ">"; then
		NAME=${LINE/>/}
		((i=i+1))
		echo -n -e "\r    $i/$PRIMERSSEQS"
	else
		ABS1=$(agrep -c -1 "$LINE" $REFERENCE)
		COUNT1=$(echo "scale=6; $ABS1/$REFSEQS" | bc)
		ABS2=$(agrep -c -2 "$LINE" $REFERENCE)
		COUNT2=$(echo "scale=6; $ABS2/$REFSEQS" | bc)
		EXPORT="TRUE"
	fi
	if [ "$EXPORT" == "TRUE" ]; then
		echo -e "$NAME\t$LINE\t0$COUNT1\t$ABS1\t0$COUNT2\t$ABS2" >> $OUT
	fi
done < "${PRIMERS}"

echo ""
echo "Done"
