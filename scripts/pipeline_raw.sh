#! bin/bash

findPrimer.py -t "target.fasta" -r "reference.fasta" -o "probes" -v

testPrimer.py -r "reference.fasta" -f "probes.fasta" -v

createConsensus.sh -t "target.fasta" -o "target_consensus.fasta"

alignPrimers.sh -c "target_consensus.fasta" -p "probes.fasta" -o "target_consensus_probes.fasta"

rateAccess.py -f "target_consensus_probes.fasta" -o "probes_access.tsv" -v

bindLogs.py -f "probes.tsv" "probes_tested.tsv" "probes_access.tsv" -o "probes_log.tsv" -r

filterPrimer.py -l "probes_log.tsv" -s 0.4 -m 0.0001 -M 0.0001 -c III -v
