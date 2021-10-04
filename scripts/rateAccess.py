#!/usr/bin/env python3

import argparse
import os
from Bio import SeqIO
from statistics import mean
import sys
import re

parser = argparse.ArgumentParser(description="Estimate the accessibility of the primers/probes in the rDNA by comparing the position to the Saccharomyces cerevisiae 18S rDNA template.")

# Add the arguments to the parser
requiredArgs = parser.add_argument_group('required arguments')

requiredArgs.add_argument("-f", "--file", dest="file_in", required=True,
					help="A fasta file with the (1) Saccharomyces cerevisiae template, (2) the consensus sequence(s) of the target file and (3) the primers/probes aligned. Note sequences will be identified by containing the words 'Saccharomyces', 'consensus' and 'primer' respectively, and prefereably will take the consensus sequence with the most abundant base as consensus to avoid ambiguities.")

parser.add_argument("-a", "--accessMap", dest="accessMap", required=False, default="/usr/local/bin/accessibilityMap.tsv",
					help="The accessibility map table. By default will assume is located in '/usr/local/bin/' and called 'accessibilityMap.tsv'.")

parser.add_argument("-o", "--output", dest="file_out", required=False,
					help="The name of the output file. Default will remove the extension of the primers/probes file and add '_access.tsv'. The file contains the following columns: the name of the primer/probe, the sequence, the first position in the target consensus sequence, the approximate region in the 18S (C1-C10, V1-V9), the first position regarding the Saccharomyces cerevisiae 18S rDNA template, the average maximun relative brightness (0-1), the average minimum relative brightness (0-1), the average relative brightness (0-1) and the given brightness class (VI-I).")

parser.add_argument("-v", "--verbose", dest="verbose", required=False, default=None, action="store_true",
					help="If selected, will print information to the console.")

args = parser.parse_args()

# Reading accessMap ________________________________________________________________________________
if args.verbose:
	print("  Reading accessibility map:", args.accessMap)
access = {}
for line in open(args.accessMap):
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
			out[position]['ungapped'] = posUngap
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
for line in SeqIO.parse(open(args.file_in), "fasta"):
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
	# But to safe memory we will only extract relevant positions
	if "primer" in name:
		p += 1
		primers[name] = extractPositionsPrimers(seq)

if "Sname" not in locals():
	print("\nError: There is no  sequence with the identifier 'Saccharomyces' in the alignment.\nExiting\n")
	sys.exit(1)

if "Cname" not in locals():
	print("\nError: There is no  sequence with the identifier 'consensus' in the alignment.\nExiting\n")
	sys.exit(1)

if args.verbose:
	print("    Saccharomyces cerevisiae template:       ", Sname)
	print("    Target group sequence template:          ", Cname)
	print("    Total primers to estimate accessibility: ", p)


# Estimating accessibility classes by matching positions ___________________________________________
if args.verbose:
	print("  Estimating accessibility")

if args.file_out is None:
        outFile = re.sub("\\.[^\\.]+$", "_access.tsv", args.file_in)
else:
        outFile = args.outFile

with open(outFile, "w") as fileOut:
	print("identifier\tsequence\tstart_position\tregion\tScerevisae_start_position\taverage_max_brightness\taverage_min_brightness\taverage_brightness\tclass", file=fileOut)
	for key in primers:
		value = primers[key]
		# Join the separated bases of the primer
		seq = "".join(value['bases'])
		seq = seq.upper()
		
		# Find the first position of the primer in the alignment
		positions = value['positions']
		start = positions[0]
		
		# Match the first position of the primer to the consensus sequence
		positionConsensus = consensus[start]['ungapped']
		
		# extract all regions from the different positions
		region = set()
		for i in positions:
			p = Scerevisae[i]['ungapped']
			region.add(access[str(p)]['region'])
		region = "-".join(region)
		
		# Match the first position of the primer to the S. cerevisae sequence
		positionScerevisae = Scerevisae[start]['ungapped']
		
		# Calculate mean maximum and minimum relative brightness
		maxb = list()
		minb = list()
		for i in positions:
			p = Scerevisae[i]['ungapped']
			maxb.append(float(access[str(p)]['brightMax']))
			minb.append(float(access[str(p)]['brightMin']))
		meanMaxBright = round(mean(maxb), 2)
		meanMinBright = round(mean(minb), 2)
		
		# Calculate mean relative brightness
		meanBright = round(mean(maxb+minb), 2)
		
		# Give the arbitrary class according to the mean relative brightness
		if meanBright <= 0.05:
			classp = "VI"
		elif  meanBright > 0.05 and meanBright <= 0.2:
			classp = "V"
		elif  meanBright > 0.2 and meanBright <= 0.4:
			classp = "IV"
		elif  meanBright > 0.4 and meanBright <= 0.6:
			classp = "III"
		elif  meanBright > 0.6 and meanBright <= 0.8:
			classp = "II"
		elif  meanBright > 0.8 and meanBright <= 1:
			classp = "I"
		else:
			classp = "NA"
		
		# And finally export all these info
		print(str(key) + "\t" + str(seq) + "\t" + str(positionConsensus) + "\t" + str(region) + "\t" + str(positionScerevisae) + "\t" + str(meanMaxBright) + "\t" + str(meanMinBright) + "\t" + str(meanBright) + "\t" + str(classp), file=fileOut)

if args.verbose:
	print("Done")

