#! bin/bash/

micromamba activate /_PATH_TO_/oligoN-design

TARGET=""
EXCLUDING=""
PREFIX="thorough"

findOligo -t ${TARGET} -e ${EXCLUDING} -l 18 20 -m 0.80 -s 0.01 -n 0 -o ${PREFIX}_find.tsv -f ${PREFIX}_find.fasta

testOligo -p ${PREFIX}_find.fasta -e ${EXCLUDING} -o ${PREFIX}_test.tsv -m "1 2"

alignOligo -t ${TARGET} -p ${PREFIX}_find.fasta -o ${PREFIX}_align.fasta
rateAccess -f ${PREFIX}_align.fasta

bindLogs -f ${PREFIX}_find.tsv ${PREFIX}_test.tsv ${PREFIX}_align_access.tsv -o ${PREFIX}_log.tsv -r

logStats -f ${PREFIX}_log.tsv

filterLog -l ${PREFIX}_log.tsv -s 0.4 0.6 -t 0.85 -k IV

table2fasta -f ${PREFIX}_log_filtered.tsv

testThorough -f ${PREFIX}_log_filtered.fasta -e ${EXCLUDING} -c 0.6 -u 7-9 -d '|'

detailed2table -f ${PREFIX}_log_filtered_testThorough.tsv
bindLogs -f ${PREFIX}_log_filtered.tsv ${PREFIX}_log_filtered_testThorough_table.tsv -o ${PREFIX}_log_filtered_tested.tsv -r
selectLog -t ${PREFIX}_log_filtered_tested.tsv -c hitsT hitsE average_brightness self-dimer_count hairpin_count mismatch1_thorough mismatch1_central0.6 mismatch2_thorough mismatch2_central0.6
