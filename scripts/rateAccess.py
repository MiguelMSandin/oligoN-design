#!/usr/bin/env python3

import argparse
import os
from Bio import SeqIO
#from Bio.Seq import Seq
#import regex
#import re

parser = argparse.ArgumentParser(description="Estimate the accessibility of the primers/probes in the rDNA by comparing the position to the Saccharomyces cerevisiae 18S rDNA template.")

# Add the arguments to the parser
requiredArgs = parser.add_argument_group('required arguments')

requiredArgs.add_argument("-f", "--file", dest="file_in", required=True,
					help="A fasta file with the (1) Saccharomyces cerevisiae template, (2) the consensus sequence(s) of the target file and (3) the primers/probes aligned. Note sequences will be identified by containing the words 'Saccharomyces', 'consensus' and 'primer' respectively, and prefereably will take the consensus sequence with the most abundant base as consensus to avoid ambiguities.")

parser.add_argument("-a", "--accessMap", dest="accessMap", required=False, default=os.path.realpath("accessibilityMap.tsv"),
					help="The accessibility map table. By default will assume is located with the script and called 'accessibilityMap.tsv'.")

parser.add_argument("-o", "--output", dest="file_out", required=False,
					help="The name of the output file. Default will remove the extension of the primers/probes file and add '_access.tsv'. The file contains the following columns: the name of the primer/probe, the sequence, the position in the target consensus file, the approximate region in the 18S (C1-C10, V1-V9), the position regarding the Saccharomyces cerevisiae 18S rDNA template, the average maximun relative brightness (0-1), the average minimum relative brightness (0-1), the average relative brightness (0-1) and the given brightness class (VI-I).")

parser.add_argument("-v", "--verbose", dest="verbose", required=False, default=None, action="store_true",
					help="If selected, will print information to the console.")

args = parser.parse_args()

# Reading accessMap ________________________________________________________________________________
if args.verbose:
	print("  Reading accessibility map:", args.accessMap)
access = {}
#for lin in open(args.accessMap):
for line in open(os.path.realpath("accessibilityMap.tsv")):
    line = line.strip().split()
    access[line[0]] = {}
    access[line[0]]['region'] = line[1]
    access[line[0]]['base'] = line[2]
    access[line[0]]['brightClass'] = line[3]
    access[line[0]]['brightMax'] = line[4]
    access[line[0]]['brightMin'] = line[5]


# Reading fasta file _______________________________________________________________________________
if args.verbose:
	print("  Reading fasta file and extracting positions")

# Create a function to extract positions of template sequences
def extractPositions(sequence):
	out = {}
	posUngap = 0
	for i in range(len(sequence)):
		position = i+1
		Sbase = sequence[i]
		out[position] = {}
		out[position]['base'] = str(Sbase)
		if Sbase == "-":
			out[position]['ungapped'] = "NA"
		else:
			posUngap += 1
			out[position]['ungapped'] = posUngap
	return out

# Create a function to extract positions of primers/probes
def extractPositionsPrimers(sequence):
	out = {}
	out['bases'] = list()
	out['positions'] = list()
	for i in range(len(sequence)):
		if sequence[i] != "-":
			out['bases'].append(sequence[i])
			out['positions'].append(i+1)
	return out

# Now loop through the file extracting positions
s = 0
c = 0
primers = {}
p = 0
#for line in SeqIO.parse(open(args.file_in), "fasta"):
for line in SeqIO.parse(open("dumies/guinardia_consensus_probes.fasta"), "fasta"):
	name = line.id
	seq = line.seq
	# First extract the template sequence of S. cerevisiae
	if "Saccharomyces" in name and s == 0:
		s += 1
		Scerevisae = extractPositions(seq)
		Sname = name
	# Extract positions of the consensus sequence with the most abundant base if present
	if "consensus" in name and "mostAbundant" in name:
		c += 1
		consensus = extractPositions(seq)
		Cname = name
	# Otherwise take the first consensus sequence present
	elif "consensus" in name and "mostAbundant" not in name and c == 0:
		c += 1
		consensus = extractPositions(seq)
		Cname = name
	# And now the primers/probes
	# But to safe memory we will only extract relevant positions now
	if "primer" in name:
		p += 1
		primers[name] = extractPositionsPrimers(seq)

if args.verbose:
	print("    Saccharomyces cerevisiae template:       ", Sname)
	print("    Target group sequence template:          ", Cname)
	print("    Total primers to estimate accessibility: ", p)
















if verbose:
	print("Done")

