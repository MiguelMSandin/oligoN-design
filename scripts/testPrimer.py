#!/usr/bin/env python3

import argparse
from Bio import SeqIO
from Bio.Seq import Seq
import regex
import re

parser = argparse.ArgumentParser(description="Given a fasta file with the primers/probes search for hits allowing mismatches against a reference file.")

# Add the arguments to the parser
requiredArgs = parser.add_argument_group('required arguments')

requiredArgs.add_argument("-f", "--file", dest="file_in", required=True,
					help="A fasta file with the primers/probes.")

requiredArgs.add_argument("-r", "--reference", dest="reference", required=True,
					help="A reference fasta file to look against.")

parser.add_argument("-o", "--output", dest="file_out", required=False,
					help="The name of the output file. Default will remove the extension of the primers/probes file and add '_log.tsv'. The file contains the following columns: the name of the primer/probe, the sequence, the length of the sequence and two columns for each given mismatch (containing the absolute number of hits in the reference file and the proportion of hits to the complete reference file) until arriving to the maximum allowed.")

parser.add_argument("-m", "--mismatch", dest="mismatch", required=False, action='store', type=int, default=2,
					help="The maximum number of mismatches allowed. Bear in mind that will look from 1 to m mismatches. Default=2")

parser.add_argument("-p", "--probe", dest="probe", required=False, default=None, action="store_true",
					help="If selected, will reverse complement the primers/probes before searching.")

parser.add_argument("-v", "--verbose", dest="verbose", required=False, default=None, action="store_true",
					help="If selected, will print information to the console.")

args = parser.parse_args()

# Setting name of the output file __________________________________________________________________
if args.verbose:
	verbose = True
	print("  Setting variables:")
else:
	verbose=False

if args.file_out is None:
	outFile = re.sub("\\.[^\\.]+$", "_log.tsv", args.file_in)
else:
	outFile = args.file_out

if verbose:
	print("    Primers file:      ", args.file_in)
	print("    Reference file:    ", args.reference)
	print("    Output file:       ", outFile)

# Setting number of mismatch _______________________________________________________________________
mismatches = args.mismatch
mismatches = range(1, int(mismatches)+1)

fields = [["name", "sequence"], ["mismatch"+str(i)+"\tmismatch"+str(i)+"_abs" for i in mismatches]]
fields = [item for l in fields for item in l]
fields = "\t".join(fields)

if verbose:
	print("    Maximum mismatches:", args.mismatch)

# Reading target file ______________________________________________________________________________
if verbose:
	print("  Reading primers file")

primers = {}
w1 = 0
for line in SeqIO.parse(open(args.file_in), "fasta"):
	if "-" in line.seq:
		sequence = re.sub("-", "", str(line.seq))
		w1 += 1
	else:
		sequence = str(line.seq)
	if args.probe is not None:
		sequence = sequence.reverse_complement()
	primers[line.id] = str(sequence.upper())

if verbose:
	print("    Number of sequences: ", str(len(primers)))

if w1 > 0:
	print("      Warning!!", args.file_in, "is aligned. Gaps will be removed for pattern matching")

# Reading reference file ___________________________________________________________________________
if verbose:
	print("  Reading reference file")

ref = {}
w2 = 0
seqs = 0
for line in SeqIO.parse(open(args.reference), "fasta"):
	seqs += 1
	if "-" in line.seq:
		sequence = re.sub("-", "", str(line.seq))
		w2 += 1
	else:
		sequence = str(line.seq)
	ref[seqs] = str(sequence.upper())

if verbose:
	print("    Number of sequences: ", str(seqs))

if w2 > 0:
	print("      Warning!!", args.reference, "is aligned. Gaps will be removed for pattern matching")

# Start the search _________________________________________________________________________________
if verbose:
	print("  Searching...")

with open(outFile, "w") as outfile:
	print(fields, file=outfile)
	p = 0
	for name, primer in primers.items():
		p += 1
		matches = []
		for m in mismatches:
			if verbose:
				print("\r    ", p, "/", len(primers), ": ", m, "/", args.mismatch, sep="", end="")
			pattern = str("(" + primer + "){e<=" + str(m) + "}")
			c = 0
			for t in ref.values():
				if len(regex.findall(pattern, t)) > 0:
					c += 1
			matches.append(str(str(c / seqs)) + "\t" + str(c))
		
		length = len(primer)
		line = [[str(name + "\t" + primer)], matches]
		line = [item for l in line for item in l]
		line = "\t".join(line)
		print(line, file=outfile)
	if verbose:
		print("    Search complete")

if verbose:
	print("Done")

