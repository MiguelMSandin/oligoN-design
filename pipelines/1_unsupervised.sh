#! bin/bash/

micromamba activate /_PATH_TO_/oligoN-design

TARGET=""
EXCLUDING=""
PREFIX="unsupervised"

oligoNdesign -t ${TARGET} -e ${EXCLUDING} -o ${PREFIX}

PREFIX2=""
oligoNdesign -t ${TARGET} -e ${EXCLUDING} -o ${PREFIX2}
