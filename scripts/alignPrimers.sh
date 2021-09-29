#!/bin/bash

usage()
{
    echo ""
    echo "A wrapper to align the consensus sequence(s) from the target file and the selected primers/probes to the Saccharomyces cerevisiae template."
    echo ""
    echo "Usage: alignPrimers.sh -c CONSENSUS -p PRIMERS -o outFile"
    echo ""
    echo "  -h    Print this information"
    echo ""
    echo "  -c    The fasta file containing the consensus sequence(s) from the target file."
    echo "  -p    The fasta file containing the selected primers/probes."
    echo "  -o    The output file name."
    echo "  -t    Prints the S. cerevisiae template to the console."
    echo "  -T    Prints the S. cerevisiae template to the specified file. If the file exists, the S. cerevisae template sequence will be appended at the end."
    echo ""
    echo ""
    echo "This wrapper uses MAFFT: https://mafft.cbrc.jp/alignment/software/"
    echo ""
    echo "Please cite:"
    echo "Katoh, Misawa, Kuma, Miyata (2002) MAFFT: a novel method for rapid multiple sequence alignment based on fast Fourier transform. Nucleic Acids Res. 30:3059-3066"
    echo ""
}

SCER="TATCTGGTTGATCCTGCCAGTAGTCATATGCTTGTCTCAAAGATTAAGCCATGCATGTCTAAGTATAAGCAATTTATACAGTGAAACTGCGAATGGCTCATTAAATCAGTTATCGTTTATTTGATAGTTCCTTTACTACATGGTATAACTGTGGTAATTCTAGAGCTAATACATGCTTAAAATCTCGACCCTTTGGAAGAGATGTATTTATTAGATAAAAAATCAATGTCTTCGGACTCTTTGATGATTCATAATAACTTTTCGAATCGCATGGCCTTGTGCTGGCGATGGTTCATTCAAATTTCTGCCCTATCAACTTTCGATGGTAGGATAGTGGCCTACCATGGTTTCAACGGGTAACGGGGAATAAGGGTTCGATTCCGGAGAGGGAGCCTGAGAAACGGCTACCACATCCAAGGAAGGCAGCAGGCGCGCAAATTACCCAATCCTAATTCAGGGAGGTAGTGACAATAAATAACGATACAGGGCCCATTCGGGTCTTGTAATTGGAATGAGTACAATGTAAATACCTTAACGAGGAACAATTGGAGGGCAAGTCTGGTGCCAGCAGCCGCGGTAATTCCAGCTCCAATAGCGTATATTAAAGTTGTTGCAGTTAAAAAGCTCGTAGTTGAACTTTGGGCCCGGTTGGCCGGTCCGATTTTTTCGTGTACTGGATTTCCAACGGGGCCTTTCCTTCTGGCTAACCTTGAGTCCTTGTGGCTCTTGGCGAACCAGGACTTTTACTTTGAAAAAATTAGAGTGTTCAAAGCAGGCGTATTGCTCGAATATATTAGCATGGAATAATAGAATAGGACGTTTGGTTCTATTTTGTTGGTTTCTAGGACCATCGTAATGATTAATAGGGACGGTCGGGGGCATCAGTATTCAATTGTCAGAGGTGAAATTCTTGGATTTATTGAAGACTAACTACTGCGAAAGCATTTGCCAAGGACGTTTTCATTAATCAAGAACGAAAGTTAGGGGATCGAAGATGATCAGATACCGTCGTAGTCTTAACCATAAACTATGCCGACTAGGGATCGGGTGGTGTTTTTTTAATGACCCACTCGGCACCTTACGAGAAATCAAAGTCTTTGGGTTCTGGGGGGAGTATGGTCGCAAGGCTGAAACTTAAAGGAATTGACGGAAGGGCACCACCAGGAGTGGAGCCTGCGGCTTAATTTGACTCAACACGGGGAAACTCACCAGGTCCAGACACAATAAGGATTGACAGATTGAGAGCTCTTTCTTGATTTTGTGGGTGGTGGTGCATGGCCGTTCTTAGTTGGTGGAGTGATTTGTCTGCTTAATTGCGATAACGAACGAGACCTTAACCTACTAAATAGTGGTGCTAGCATTTGCTGGTTATCCACTTCTTAGAGGGACTATCGGTTTCAAGCCGATGGAAGTTTGAGGCAATAACAGGTCTGTGATGCCCTTAGACGTTCTGGGCCGCACGCGCGCTACACTGACGGAGCCAGCGAGTCTAACCTTGGCCGAGAGGTCTTGGTAATCTTGTGAAACTCCGTCGTGCTGGGGATAGAGCATTGTAATTATTGCTCTTCAACGAGGAATTCCTAGTAAGCGCAAGTCATCAGCTTGCGTTGATTACGTCCCTGCCCTTTGTACACACCGCCCGTCGCTAGTACCGATTGAATGGCTTAGTGAGGCCTCAGGATCTGCTTAGAGAAGGGGGCAACTCCATCTCAGAGCGGAGAATTTGGACAAACTTGGTCATTTAGAGGAACTAAAAGTCGTAACAAGGTTTCCGTAGGTGAACCTGCGGAAGGATCATTA"

while getopts "hc:p:o:tT:" opt; do
        case ${opt} in
                h )
                        usage
                        exit
                        ;;
                c )
                        CONSENSUS=$OPTARG
                        ;;
                p )
                        PRIMERS=$OPTARG
                        ;;
                o )
                        OUT=$OPTARG
                        ;;
                t )
                        echo ""
                        echo "  Saccharomyces cerevisiae template sequence:"
                        echo "$SCER"
                        echo ""
                        exit
                        ;;
                T )
                        TEMPLATE=$OPTARG
                        echo -e ">Saccharomyces_cerevisiae_template\n$SCER" >> $TEMPLATE
                        exit
                        ;;
        esac
done

# Create temporary files
tmp1=$(mktemp --tmpdir=$(pwd))
tmp2=$(mktemp --tmpdir=$(pwd))

# Export a S. cerevisiae template file
echo -e ">Saccharomyces_cerevisiae_template\n$SCER" > $tmp1
# Merge with the consensus sequences
cat $tmp1 $CONSENSUS > $tmp2

# Align S. cerevisiae template and consensus
echo "  Aligning Saccharomyces cerevisiae template and consensus sequence(s)"
mafft --quiet $tmp2 > $tmp1

# Now align the primers/probes to the aligned file
echo "  Aligning primers/probes to Saccharomyces cerevisiae template and consensus sequence(s)"
mafft --quiet --addfragments $PRIMERS $tmp1 > $OUT

# And removing temporary files
rm -f $tmp1 $tmp2

echo "Done"

