#!/bin/bash

usage()
{
    echo ""
    echo "A wrapper to align selected primers/probes to the Saccharomyces cerevisiae template and the consensus sequence(s) from the target file."
    echo ""
    echo "Usage: alignPrimers.sh -c CONSENSUS -p PRIMERS -o outFile"
    echo ""
    echo "  -h    Print this information"
    echo ""
    echo "As input file either -t or -c:"
    echo "  -t    The fasta file containing the target group"
    echo "  -c    The fasta file containing the consensus sequence(s) from the target file."
    echo ""
    echo "  -p    The fasta file containing the selected primers/probes."
    echo "  -o    The output file name."
    echo ""
    echo "  -s    Prints the S. cerevisiae template to the console."
    echo "  -S    Prints the S. cerevisiae template to the specified file. If the file exists, the S. cerevisae template sequence will be appended at the end."
    echo ""
    echo ""
    echo "This wrapper uses MAFFT: https://mafft.cbrc.jp/alignment/software/"
    echo ""
    echo "Please cite:"
    echo "Katoh, Misawa, Kuma, Miyata (2002) MAFFT: a novel method for rapid multiple sequence alignment based on fast Fourier transform. Nucleic Acids Res. 30:3059-3066"
    echo ""
}

SCER="TATCTGGTTGATCCTGCCAGTAGTCATATGCTTGTCTCAAAGATTAAGCCATGCATGTCTAAGTATAAGCAATTTATACAGTGAAACTGCGAATGGCTCATTAAATCAGTTATCGTTTATTTGATAGTTCCTTTACTACATGGTATAACTGTGGTAATTCTAGAGCTAATACATGCTTAAAATCTCGACCCTTTGGAAGAGATGTATTTATTAGATAAAAAATCAATGTCTTCGGACTCTTTGATGATTCATAATAACTTTTCGAATCGCATGGCCTTGTGCTGGCGATGGTTCATTCAAATTTCTGCCCTATCAACTTTCGATGGTAGGATAGTGGCCTACCATGGTTTCAACGGGTAACGGGGAATAAGGGTTCGATTCCGGAGAGGGAGCCTGAGAAACGGCTACCACATCCAAGGAAGGCAGCAGGCGCGCAAATTACCCAATCCTAATTCAGGGAGGTAGTGACAATAAATAACGATACAGGGCCCATTCGGGTCTTGTAATTGGAATGAGTACAATGTAAATACCTTAACGAGGAACAATTGGAGGGCAAGTCTGGTGCCAGCAGCCGCGGTAATTCCAGCTCCAATAGCGTATATTAAAGTTGTTGCAGTTAAAAAGCTCGTAGTTGAACTTTGGGCCCGGTTGGCCGGTCCGATTTTTTCGTGTACTGGATTTCCAACGGGGCCTTTCCTTCTGGCTAACCTTGAGTCCTTGTGGCTCTTGGCGAACCAGGACTTTTACTTTGAAAAAATTAGAGTGTTCAAAGCAGGCGTATTGCTCGAATATATTAGCATGGAATAATAGAATAGGACGTTTGGTTCTATTTTGTTGGTTTCTAGGACCATCGTAATGATTAATAGGGACGGTCGGGGGCATCAGTATTCAATTGTCAGAGGTGAAATTCTTGGATTTATTGAAGACTAACTACTGCGAAAGCATTTGCCAAGGACGTTTTCATTAATCAAGAACGAAAGTTAGGGGATCGAAGATGATCAGATACCGTCGTAGTCTTAACCATAAACTATGCCGACTAGGGATCGGGTGGTGTTTTTTTAATGACCCACTCGGCACCTTACGAGAAATCAAAGTCTTTGGGTTCTGGGGGGAGTATGGTCGCAAGGCTGAAACTTAAAGGAATTGACGGAAGGGCACCACCAGGAGTGGAGCCTGCGGCTTAATTTGACTCAACACGGGGAAACTCACCAGGTCCAGACACAATAAGGATTGACAGATTGAGAGCTCTTTCTTGATTTTGTGGGTGGTGGTGCATGGCCGTTCTTAGTTGGTGGAGTGATTTGTCTGCTTAATTGCGATAACGAACGAGACCTTAACCTACTAAATAGTGGTGCTAGCATTTGCTGGTTATCCACTTCTTAGAGGGACTATCGGTTTCAAGCCGATGGAAGTTTGAGGCAATAACAGGTCTGTGATGCCCTTAGACGTTCTGGGCCGCACGCGCGCTACACTGACGGAGCCAGCGAGTCTAACCTTGGCCGAGAGGTCTTGGTAATCTTGTGAAACTCCGTCGTGCTGGGGATAGAGCATTGTAATTATTGCTCTTCAACGAGGAATTCCTAGTAAGCGCAAGTCATCAGCTTGCGTTGATTACGTCCCTGCCCTTTGTACACACCGCCCGTCGCTAGTACCGATTGAATGGCTTAGTGAGGCCTCAGGATCTGCTTAGAGAAGGGGGCAACTCCATCTCAGAGCGGAGAATTTGGACAAACTTGGTCATTTAGAGGAACTAAAAGTCGTAACAAGGTTTCCGTAGGTGAACCTGCGGAAGGATCATTA"

while getopts "hc:t:p:o:sS:" opt; do
        case ${opt} in
                h )
                        usage
                        exit
                        ;;
                t )
                        TARGET=$OPTARG
                        ;;
                c )
                        CONSENSUS=$OPTARG
                        if [ ! -z ${TARGET+x} ] && [ ! -z ${CONSENSUS+x} ]; then
                            echo ""
                            echo "Warning! Please select either a target file (with -t) or a consensus sequence(s) file (with -c), but not both"
                            echo ""
                            exit
                        fi
                        ;;
                p )
                        PRIMERS=$OPTARG
                        ;;
                o )
                        OUT=$OPTARG
                        ;;
                s )
                        echo ""
                        echo "  Saccharomyces cerevisiae template sequence:"
                        echo "$SCER"
                        echo ""
                        exit
                        ;;
                S )
                        TEMPLATE=$OPTARG
                        echo -e ">Saccharomyces_cerevisiae_template\n$SCER" >> $TEMPLATE
                        exit
                        ;;
        esac
done

if [ -z ${TARGET+x} ]; then
	echo "Input file: $CONSENSUS"
	echo "Primers:    $PRIMERS"
	echo ""
else
	echo "Input file: $TARGET"
	echo "Primers:    $PRIMERS"
	echo ""
	# Creat temporary files
	tmp1=$(mktemp --tmpdir=$(pwd))
	
	# Align target file
	echo "  Aligning target file"
	mafft --quiet $TARGET > $tmp1
	
	CONSENSUS=$(mktemp --tmpdir=$(pwd))
	# Create consensus sequences using the most abundant base to resolve ambiguous positions
	echo "  Generating consensus sequence with the most abundant base"
	alignmentConsensus.py -f $tmp1 -o $CONSENSUS -r -m
	# Create consensus sequences allowing ambiguous positions
	echo "  Generating consensus sequence allowing ambiguities"
	alignmentConsensus.py -f $tmp1 -o $CONSENSUS -r
	
	# Changing the name of the consensus sequence
	sed -i -E 's/.*tmp/>/g' $CONSENSUS
	sed -i "s\>_\>$TARGET\g" $CONSENSUS
	sed -i 's/.fasta/_/g' $CONSENSUS
fi

# Export a S. cerevisiae template file
tmp2=$(mktemp --tmpdir=$(pwd))
echo -e ">Saccharomyces_cerevisiae_template\n$SCER" > $tmp2
tmp3=$(mktemp --tmpdir=$(pwd))
# Merge with the consensus sequences
cat $tmp2 $CONSENSUS > $tmp3

# Align S. cerevisiae template and consensus
echo "  Aligning Saccharomyces cerevisiae template and consensus sequence(s)"
mafft --quiet $tmp3 > $tmp2

# Now align the primers/probes to the aligned file
echo "  Aligning primers/probes to Saccharomyces cerevisiae template and consensus sequence(s)"
mafft --quiet --addfragments $PRIMERS $tmp2 > $OUT

# And removing temporary files
if [ -z ${TARGET+x} ]; then
	rm -f $tmp2 $tmp3
else
	rm -f $tmp1 $tmp2 $tmp3 $CONSENSUS
fi

echo ""
echo "Output file writen to: $OUT"
echo "Done"

