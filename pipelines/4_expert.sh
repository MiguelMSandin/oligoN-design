#! bin/bash/

micromamba activate /_PATH_TO_/oligoN-design

TARGET=""
EXCLUDING=""
PREFIX="expert"

findOligo -t ${TARGET} -e ${EXCLUDING} -l 30 25 20 15 -o ${PREFIX}_find.tsv -f ${PREFIX}_find.fasta

identifyRegions -f ${PREFIX}_find.fasta -o ${PREFIX}_regions.tsv -e ${PREFIX}_regions.fasta

mafft ${TARGET} > ${TARGET/.fasta/_align.fasta}
mafft --addfragments ${PREFIX}_regions.fasta ${TARGET/.fasta/_align.fasta} > ${TARGET/.fasta/_align_regions.fasta}

trimRegion -f ${TARGET/.fasta/_align.fasta} -s ${PREFIX}_regions.fasta -d regions -n

for FILE in $(ls regions/*); do
	getHomologRegion -f ${FILE} -e ${EXCLUDING} -t
done

getHomologStats -f regions/*homologRegion* -t -p
