#! bin/bash/

micromamba activate /_PATH_TO_/oligoN-design

TARGET=""
EXCLUDING=""
PREFIX="basic"

findOligo -t ${TARGET} -e ${EXCLUDING} -l 18 20 -m 0.80 -s 0.01 -n 0 -o ${PREFIX}_find.tsv -f ${PREFIX}_find.fasta

testOligo -p ${PREFIX}_find.fasta -e ${EXCLUDING} -o ${PREFIX}_test.tsv -m "1 2"

alignOligo -t ${TARGET} -p ${PREFIX}_find.fasta -o ${PREFIX}_align.fasta
rateAccess -f ${PREFIX}_align.fasta

bindLogs -f ${PREFIX}_find.tsv ${PREFIX}_test.tsv ${PREFIX}_align_access.tsv -o ${PREFIX}_log.tsv -r

selectLog -t ${PREFIX}_log.tsv -c hitsT hitsE mismatch1_indel mismatch2_indel average_brightness -n 4
