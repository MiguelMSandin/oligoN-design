#!/usr/bin/env python3

import argparse
from Bio import SeqIO
import sys
import time
import threading

start_time = time.time()

parser = argparse.ArgumentParser(description="From a targeted fasta file (t/target), find all possible specific primers/probes of length 'l', that matches at least 'm%' of the sequences (or 'M' sequences) in the targeted file and has a maximum specificity of 's%' of the sequences (or 'S' sequences) to the reference (r/reference) database.",
								 epilog="*The basic melting temperature (Tm) is an approximation and should be considered as a baseline for comparison. Briefly, for short primers (<14 bp): Tm = 2*(A+T) + 4*(G+C); and for longer primers (>13 bp): Tm = 64.9 + 41*(G+C - 16.4) / (A+G+C+T); where A, C, G and T are the number of bases of A, G, C and T respectively.")

# Add the arguments to the parser
requiredArgs = parser.add_argument_group('required arguments')

requiredArgs.add_argument("-t", "--target", required=True,
					help="A fasta file with the sequences you want to find a primer to.")

requiredArgs.add_argument("-r", "--reference", dest="reference", required=True,
					help="A reference file to look against. The targeted group shouldn't be included in the reference. If you are not sure whether it is included or not use the option '-s/--specificity'.")

requiredArgs.add_argument("-o", "--output", dest="output", required=True,
					help="The name of the output fasta and log files. Please note the extensions '.fasta' and '.tsv' will be added to the specify name respectively ('output.fasta' and 'output.tsv'). The output file contains the follwing columns: the primer name, the length of the sequence, the sequence, the reverse complement sequence (if selected), the GC content, the basic melting temperature*, the proportion of hits in the reference file, the number of hits in the reference file, the proportion of hits in the target file and the number of hits in the target file.")

parser.add_argument("-l", "--length", dest="length", required=False, action='store', default='18-22',
					help="The desire length of the primers to be searched. A range can be specified with the '-' sign or several lengths can be selected by separating them with a '+' sign in between. By default it will look for primers of length 18, 19, 20, 21 and 22 base pairs ('18-22').")

parser.add_argument("-s", "--specificity", dest="specificity", required=False, action='store', type=float, default=0.01,
					help="The maximum percentage of sequences that can contain the primer in the reference file (0 >= s >= 1). Default = 0.001")

parser.add_argument("-m", "--minimum", dest="minimum", required=False, action='store', type=float, default=0.8,
					help="The minimum percentage of sequences that the primer has to appear in the target file (0 >= m >= 1). Default = 0.8")

parser.add_argument("-S", "--specificityAbs", dest="specificityAbs", required=False, action='store', type=int, default=None,
					help="Same as '-s/--specificity' but absolute values.")

parser.add_argument("-M", "--minimumAbs", dest="minimumAbs", required=False, action='store', type=int, default=None,
					help="Same as '-m/--minimum' but absolute values.")

parser.add_argument("-p", "--probe", dest="probe", required=False, action='store', type=int, default=1,
					help="If selected, will also return in the logfile the reverse complement of the primer to be used for reverse primers or probes.")

parser.add_argument("-T", "--threads", dest="threads", required=False, default=None, action="store_true",
					help="If selected, will also return in the logfile the reverse complement of the primer to be used for reverse primers or probes.")

parser.add_argument("-v", "--verbose", dest="verbose", required=False, default=None, action="store_true",
					help="If selected, will print information to the console.")

args = parser.parse_args()

if args.verbose is not None:
	verbose = True
	print("  Setting variables...")
else:
	verbose = False

# Setting the range of lengths _____________________________________________________________________
if '+' in args.length and '-' in args.length:
	print("  Warning! Please select either a range with '-' or specific lengths with '+', but not both.")
	sys.exit(1)
elif '+' in args.length:
	tmp = args.length.strip().split('+')
	lengths = list()
	for l in tmp:
		lengths.append(int(l))
elif '-' in args.length:
	mi = args.length.split('-')[0]
	ma = args.length.split('-')[1]
	lengths = range(int(mi), int(ma)+1)
else:
	lengths = int(args.length)
if verbose:
	print("    Lengths:    ", *lengths)

# Setting the specificities ________________________________________________________________________
if args.specificityAbs is not None:
	specificity = args.specificityAbs
	ext = "sequences"
elif args.specificity != 0.001:
	specificity = args.specificity
	ext = "%"
	if args.specificityAbs is not None:
		print("    Warning!! '-s/--specificity' has been parsed by '-S/--specificityAbs'. Taking absolute values.")
else:
	specificity = 0.001
	ext = "%"
	if args.specificityAbs is not None:
		print("    Warning!! '-s/--specificity' has been parsed by '-S/--specificityAbs'. Taking absolute values.")
if verbose:
	print("    Specificity:", specificity, ext)

if args.minimumAbs is not None:
	minimum = args.minimumAbs
	ext = "sequences"
elif args.minimum != 0.8:
	minimum = args.minimum
	ext = "%"
else:
	minimum = 0.8
	ext = "%"
	if args.minimumAbs is not None:
		print("    Warning!! '-m/--minimum' has been parsed by '-M/--minimumAbs'. Taking absolute values.")
if verbose:
	print("    Minimum:    ", minimum, ext)

if args.probe is not None:
	from Bio.Seq import Seq
	if verbose:
		print("    Reverse-complement option selected (-p/--probe)")

# Reading target file ______________________________________________________________________________
if verbose:
	print("  Reading target file...", end="")

target = {}
w1 = 0
for line in SeqIO.parse(open(args.target), "fasta"):
	target[line.id] = str(line.seq.upper())
	if "-" in line.seq:
		w1 += 1

if verbose:
	print("\r    Sequences in target file ('", str(args.target), "'):   ", len(target), sep="")
	if w1 > 0:
		print("    Warning!!", args.target, "contains gaps")

# Reading reference file ___________________________________________________________________________
if verbose:
	print("  Reading reference file...", end="")

ref = {}
w2 = 0
for line in SeqIO.parse(open(args.reference), "fasta"):
	ref[line.id] = str(line.seq.upper())
	if "-" in line.seq:
		w2 += 1

if verbose:
	print("\r    Sequences in reference file ('", str(args.reference), "'):   ", len(ref), sep="")
	if w2 > 0:
		print("    Warning!!", args.reference, "contains gaps")

# Start the search _________________________________________________________________________________
primers = set()
logFile = str(args.output + ".tsv")
fasFile = str(args.output + ".fasta")
with open(logFile, "w") as logfile, open(fasFile, "w") as fasfile:
	if args.probe is not None:
		print("identifier\tlength\tsequence\tsequence_reverseComplement\tGC\tTm\thits_target\thits_target_absolute\thits_reference\thits_reference_absolute", file=logfile)
	else:
		print("identifier\tlength\tsequence\tGC\tTm\thits_target\thits_target_absolute\thits_reference\thits_reference_absolute", file=logfile)
	for length in lengths:  # Loop through the different lengths
		if verbose:
			print("  Searching primers of", str(length), "base pairs...")
			i = 0
		for tv in target.values():  # Loop through all the sequences in the target file
			if verbose:
				i += 1
				print("\r    ", str(i), "/", len(target), sep="", end="")
				if i == len(target):
					print("\r    Completed")
			l = len(tv)
			for p in range(0, l-length+1):  # Split the target ith sequence into potential primers of length 'l'
				pprimer = tv[int(p):(int(p+length))]
				if pprimer not in primers:  # Check if the potential primer is already in the list
					r = sum(pprimer in i for i in target.values())  # Count how many times the potential primer is repeated in the target file
					if args.minimumAbs is not None:  # Check if the potential primer is repeated more than 'M' times
						R = r
					else:  # Check if the potential primer is repeated more than 'm' times
						R = r/len(target)
					if R >= minimum:  # Check if the potential primer matches the requirements against the target file
						c = sum(pprimer in i for i in ref.values()) # Count how many times the potential primer is repeated in the reference file
						if args.specificityAbs is not None:  # Check if the potential primer is repeated less than 'S' times
							C = c
						else:  # Check if the potential primer is repeated less than 's' times
							C = c/len(ref)
						if C <= specificity:  # Check if the potential primer matches the requirements against the reference file
								primers.add(pprimer)
								# Estimate the GC content
								gcs = pprimer.upper().count("G") + pprimer.upper().count("C")
								length = len(pprimer)
								GC = round((gcs) / length, 4)
								# Estimate the theoretical melting temperature
								if length < 14:
									Tm = 2 * (pprimer.upper().count("A") + pprimer.upper().count("T")) + 4 * (gcs)
								else:
									Tm = 64.9 + 41*(gcs - 16.4) / length
								Tm = round(Tm, 2)
								# And export
								if args.probe is not None:
									print("primer" + str(len(primers)) + "\t" + str(len(pprimer)) + "\t" + str(pprimer) + "\t" + str(Seq(pprimer).reverse_complement()) + "\t" + str(GC) + "\t" + str(Tm) + "\t" + str(r/len(target)) + "\t" + str(r) + "\t" + str(c/len(ref)) + "\t" + str(c), file=logfile)
									print(">primer" + str(len(primers)) + "\n" + str(pprimer), file=fasfile)
								else:
									print("primer" + str(len(primers)) + "\t" + str(len(pprimer)) + "\t" + str(pprimer) + "\t" + str(GC) + "\t" + str(Tm) + "\t" + str(r/len(target)) + "\t" + str(r) + "\t" + str(c/len(ref)) + "\t" + str(c), file=logfile)
									print(">primer" + str(len(primers)) + "\n" + str(pprimer), file=fasfile)

if verbose:
	t = time.time() - start_time
	t = round(t/60, 2)
	print("It took", t, "minutes to complete")
	print("Done")
