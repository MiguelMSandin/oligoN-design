#!bin/bash/

oligoNactivate

# alignmentConsensus ------------------------------------------------------------------------------
mafft mast1.fasta > mast1_align.fasta

alignmentConsensus -f mast1_align.fasta

alignmentConsensus -f mast1_align.fasta -t 0.5 -b 0.4 -g 0.6 -r

alignmentConsensus -f mast1_align.fasta -t 0.9 -b 0.1 -g 0.9 -o mast1_align_cons.fasta
alignmentConsensus -f mast1_align.fasta -m -o mast1_align_cons.fasta

rm -f mast1_align*

# alignOligo --------------------------------------------------------------------------------------
alignOligo -t mast3.fasta -p oligos.fasta

alignOligo -s

rm -f oligos_*

# bindLogs ----------------------------------------------------------------------------------------
testOligo -e rads.fasta -p oligos.fasta
filterLog -l oligos_tested.tsv -m 0.8
alignOligo -t rads.fasta -p oligos.fasta
rateAccess -f oligos_aligned.fasta

bindLogs -f oligos_tested_filtered.tsv oligos_aligned_access.tsv -o oligos_log.tsv -d

bindLogs -f oligos_tested.tsv oligos_aligned_access.tsv -o oligos_log.tsv -r

rm -f oligos_*

# breakFasta --------------------------------------------------------------------------------------

breakFasta -f mast1.fasta -e mast1_kmers.fasta -p

breakFasta -f mast1.fasta -l 18-22 -m 15 20 25 -e mast1_kmers.fasta -s -a 20

rm -f mast1_*

# detailed2table ----------------------------------------------------------------------------------
testThorough -f oligos.fasta -e mast3.fasta

detailed2table -f oligos_testThorough.tsv

rm -f oligos_*

# fastaChangeBases --------------------------------------------------------------------------------

fastaChangeBases -f rads.fasta -c T U

fastaChangeBases -f rads.fasta -a

fastaChangeBases -f rads.fasta -l

rm -f rads_*

# fastaRevCom -------------------------------------------------------------------------------------

fastaRevCom -f oligos.fasta

fastaRevCom -f oligos.fasta -c

fastaRevCom -f oligos.fasta -r

rm -f oligos_*

# filterLog ---------------------------------------------------------------------------------------
testOligo -e mast1.fasta -p oligos.fasta

filterLog -l oligos_tested.tsv -m 0.001

rm -f oligos_*

# findOligo ---------------------------------------------------------------------------------------
sequenceSelect -f mast3.fasta -p 3A -o mast3_target.fasta
sequenceSelect -f mast3.fasta -p 3A -o mast3_excluding.fasta -r

findOligo -t mast3_target.fasta -e mast3_excluding.fasta

findOligo -t mast3_target.fasta -e mast3_excluding.fasta -p mast3_probes.fasta

findOligo -t mast3_target.fasta -e mast3_excluding.fasta -l 30 25 22-15 -m 0.95 -s 10 -f mast3_oligos.fasta

rm -f mast3_*

# getHomolog --------------------------------------------------------------------------------------
getMismatchSeq -s CCAGCTCCAATAGCGTATAC -e rads.fasta -m 1 -o homolog.fasta
sequenceSelect -f rads.fasta -p Coll -o homolog_exc.fasta

getHomolog -f homolog.fasta -e homolog_exc.fasta -s 0.8

rm -f homolog*

# getHomologStats ---------------------------------------------------------------------------------
getMismatchSeq -s CCAGCTCCAATAGCGTATAC -e rads.fasta -m 1-3 -o homolog.fasta

getHomologStats -f homolog.fasta -p

rm -f homolog*

# getMismatchSeq ----------------------------------------------------------------------------------
sequenceSelect -f mast1.fasta -p 1A -o excl_mismatches.fasta -r

getMismatchSeq -s TTTGCGGATCGAGGTAAT -e excl_mismatches.fasta -m 1-3 -n NS1A

rm -f *mismatches*

# hairPins ----------------------------------------------------------------------------------------

hairPins -s CCAGCTCCAATAGCGTATAC

hairPins -s ACGTCGATGACGT -b 5 -r

# identifyRegions ---------------------------------------------------------------------------------
sequenceSelect -f mast3.fasta -p 3A -o mast3_target.fasta
sequenceSelect -f mast3.fasta -p 3A -o mast3_excluding.fasta -r
findOligo -t mast3_target.fasta -e mast3_excluding.fasta -l 20 -f mast3_oligos.fasta

identifyRegions -f mast3_oligos.fasta -e mast3_regions.fasta

rm -f mast3_*

# logStats ----------------------------------------------------------------------------------------
sequenceSelect -f rads.fasta -p Acantharea -o rads_target.fasta
sequenceSelect -f rads.fasta -p Acantharea -o rads_excluding.fasta -r
findOligo -t rads_target.fasta -e rads_excluding.fasta

logStats -f rads_target_oligos.tsv

logStats -f rads_target_oligos.tsv -c hitsT_prop -p

rm -f rads_*

# multi2linefasta ---------------------------------------------------------------------------------

multi2linefasta -f mast1.fasta

multi2linefasta -f mast1.fasta -r

rm -f mast1_*

# oligoNdesign ------------------------------------------------------------------------------------
sequenceSelect -f mast3.fasta -p 3A -o mast3_target.fasta
sequenceSelect -f mast3.fasta -p 3A -o mast3_excluding.fasta -r

oligoNdesign -t mast3_target.fasta -e mast3_excluding.fasta -o mast3_oligos

oligoNdesign -t mast3_target.fasta -e mast3_excluding.fasta -o mast3_oligos_quick -f -k -n 10

rm -f mast3_*

# oligoNtest --------------------------------------------------------------------------------------

oligoNtest

# rateAccess --------------------------------------------------------------------------------------
alignOligo -t rads.fasta -p oligos.fasta

rateAccess -f oligos_aligned.fasta

rateAccess -e access_map.tsv -a 16S

rm -f oligos_* access*

# selectLog ---------------------------------------------------------------------------------------
sequenceSelect -f mast1.fasta -p 1A -o mast1_target.fasta
sequenceSelect -f mast1.fasta -p 1A -o mast1_excluding.fasta -r
findOligo -t mast1_target.fasta -e mast1_excluding.fasta -c 0.6

selectLog -f mast1_target_oligos.tsv \
	-c hitsT hitsE mismatch1 mismatch2 mismatch1_central0.6 \
	-r d a a a a \
	-w 1 1 1 0.2 2 \
	-n 10 -o mast1_target_oligos_selected.tsv

rm -f mast1_*

# selfDimer ---------------------------------------------------------------------------------------

selfDimer -s CCAGCTCCAATAGCGTATAC

selfDimer -s ACGTCGATGACGT -b 8 -r

# sequenceSelect ----------------------------------------------------------------------------------

grep GU mast3.fasta | sed 's/>//g' > mast3_names.list
sequenceSelect -f mast3.fasta -l mast3_names.list

sequenceSelect -f mast3.fasta -o mast3_target.fasta -p 3I

sequenceSelect -f mast3.fasta -o mast3_excluding.fasta -p 3I -r

rm -f mast3_*

# table2fasta -------------------------------------------------------------------------------------
sequenceSelect -f rads.fasta -p Acantharea -o rads_target.fasta
sequenceSelect -f rads.fasta -p Acantharea -o rads_excluding.fasta -r
findOligo -t rads_target.fasta -e rads_excluding.fasta -o rads_oligos.tsv

table2fasta -f rads_oligos.tsv

table2fasta -f rads_oligos.tsv -c 1 3 -o rads_oligos_revCom.fasta

rm -f rads_*

# testOligo ---------------------------------------------------------------------------------------
testOligo -e mast1.fasta -p oligos.fasta -m '3 4'

rm -f oligos_*

# testTarget --------------------------------------------------------------------------------------

testTarget -t mast1.fasta -f oligos.fasta -m 0-2 -d mast1_testTarget.fasta

rm -f mast1_*

# testThorough ------------------------------------------------------------------------------------

testThorough -f oligos.fasta -e mast3.fasta -b 3 -c 0.6 -i -t oligos_testThoroughTable.tsv

testThorough -f oligos.fasta -e mast3.fasta -n -u 7 8 -d '|'

rm -f oligos_*

# trimRegion --------------------------------------------------------------------------------------
mafft rads.fasta > rads_align.fasta

trimRegion -f rads_align.fasta -r CCAGCTCCAATAGCGTATAC CAGGTCTGTGATGCCC -d regions

trimRegion -f rads_align.fasta -p 600-1100 -k -o rads_align_V4.fasta

trimRegion -f rads_align.fasta -s oligos.fasta -d regions -n

rm -fr regions* rads_*
