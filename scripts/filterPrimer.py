#!/usr/bin/env python3

import argparse
import pandas as pd
import re
import sys

parser = argparse.ArgumentParser(description="Based on several user-defined threshold, the logFile will filter primers that do not meet the criteria")

# Add the arguments to the parser
requiredArgs = parser.add_argument_group('required arguments')

requiredArgs.add_argument("-l", "--logFile", dest="logFile", required=True,
					help="The name of the input logFile to be filtered.")

parser.add_argument("-o", "--outFile", dest="outFile", required=False, default=None,
					help="The name of the output log file. By default, will add '_filtered.tsv' to the input logFile.")

parser.add_argument("-s", "--GCcontent", dest="GCcontent", required=False, action='store', type=float, default=None,
					help="A minimum GC content percentage allowed (0-1).")

parser.add_argument("-t", "--Tm", dest="Tm", required=False, action='store', type=float, default=None,
					help="A minimum melting temperature allowed.")

parser.add_argument("-m", "--mismatch1", dest="mismatch1", required=False, action='store', type=float, default=None,
					help="A maximum percentage of of hits allowing 1 mismatch (0-1).")

parser.add_argument("-M", "--mismatch2", dest="mismatch2", required=False, action='store', type=float, default=None,
					help="A maximum percentage of of hits allowing 2 mismatchs (0-1).")

parser.add_argument("-r", "--region", dest="region", required=False, action='store', default=None,
					help="A desired region in the 18S rDNA (C1-C10, V1-V9).")

parser.add_argument("-c", "--class", dest="classb", required=False, action='store', default=None,
					help="A minimum brightness class (I > II > III > IV > V > VI)")

parser.add_argument("-b", "--brightness", dest="brightness", required=False, action='store', type=float, default=None,
					help="A minimum relative mean brightness (0-1).")

parser.add_argument("-v", "--verbose", dest="verbose", required=False, default=None, action="store_true",
					help="If selected, will print information to the console.")

args = parser.parse_args()

choiceRegion=('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'V1', 'V2', 'V3', 'V4', 'V5', 'V6', 'V7', 'V8', 'V9')
if args.region is not None and args.region not in choiceRegion:
	print("  Warning! Region must be among the following choices:\n", choiceRegion)
	sys.exit(1)

choiceClass= ('I', 'II', 'III', 'IV', 'V', 'VI')
if args.region is not None and args.classb not in choiceClass:
	print("  Warning! Class must be among the following choices:\n", choiceClass)
	sys.exit(1)

# Setting output file name _________________________________________________________________________
if args.outFile is None:
        outFile = re.sub("\\.[^\\.]+$", "_filtered.tsv", args.logFile)
else:
        outFile = args.outFile

if args.verbose:
	print("    File in:  ", args.logFile)
	print("    File out: ", outFile)
	print("  Filtering")

# Start filtering __________________________________________________________________________________
#infile = pd.read_csv(args.logFile, sep="\t")
infile = pd.read_csv("probes_log.tsv", sep="\t")

outfile = infile

if args.GCcontent is not None:
	outfile = outfile[outfile['GC'] >= args.GCcontent]
	if args.verbose:
		print("    Probes passing GC criteria: ", len(infile[infile['GC'] >= args.GCcontent]))

if args.Tm is not None:
	outfile = outfile[outfile['Tm'] >= args.Tm]
	if args.verbose:
		print("    Probes passing Tm criteria: ", len(infile[infile['Tm'] >= args.Tm]))

if args.mismatch1 is not None:
	outfile = outfile[outfile['mismatch1'] <= args.mismatch1]
	if args.verbose:
		print("    Probes passing mismatch1 criteria: ", len(infile[infile['mismatch1'] <= args.mismatch1]))

if args.mismatch2 is not None:
	outfile = outfile[outfile['mismatch2'] <= args.mismatch2]
	if args.verbose:
		print("    Probes passing mismatch2 criteria: ", len(infile[infile['mismatch2'] <= args.mismatch2]))

if args.region is not None:
	outfile = outfile[outfile['region'].str.contains(args.region)]
	if args.verbose:
		print("    Probes passing region criteria: ", len(infile[infile['region'].str.contains(args.region)]))

if args.classb is not None:
	if args.classb == 'I':
		outfile = outfile[outfile['class'] == "I"]
		if args.verbose:
			print("    Probes passing class criteria: ", len(infile[infile['class'] == "I"]))
	
	elif args.classb == 'II':
		outfile = outfile[(outfile['class'] == "I") | (outfile['class'] == "II")]
		if args.verbose:
			print("    Probes passing class criteria: ", len(infile[(infile['class'] == "I") | (infile['class'] == "II")]))
	
	elif args.classb == 'III':
		outfile = outfile[(outfile['class'] == "I") | (outfile['class'] == "II") | (outfile['class'] == "III")]
		if args.verbose:
			print("    Probes passing class criteria: ", len(infile[(infile['class'] == "I") | (infile['class'] == "II") | (infile['class'] == "III")]))
	
	elif args.classb == 'IV':
		outfile = outfile[(outfile['class'] == "I") | (outfile['class'] == "II") | (outfile['class'] == "III") | (outfile['class'] == "IV")]
		if args.verbose:
			print("    Probes passing class criteria: ", len(infile[(infile['class'] == "I") | (infile['class'] == "II") | (infile['class'] == "III") | (infile['class'] == "IV")]))
	
	elif args.classb == 'V':
		outfile = outfile[outfile['class'] != "VI"]
		if args.verbose:
			print("    Probes passing class criteria: ", len(infile[infile['class'] != "VI"]))

if args.brightness is not None:
	outfile = outfile[outfile['average_brightness'] >= args.brightness]
	if args.verbose:
		print("    Probes passing brightness criteria: ", len(infile[infile['average_brightness'] >= args.brightness]))

# Exporting ----------------------------------------------------------------------------------------
outfile.to_csv(outFile, sep="\t", index=False)

if args.verbose:
	print("  Primers in:  ", len(infile))
	print("  Primers out: ", len(outfile))
	print("Done")
