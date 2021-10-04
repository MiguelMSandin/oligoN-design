#!/usr/bin/env python3

import argparse
import pandas as pd

parser = argparse.ArgumentParser(description="Binds the columns from the log outputs of findPrimer.py, testPrimer.py and/or rateAccess.py.")

# Add the arguments to the parser
requiredArgs = parser.add_argument_group('required arguments')

requiredArgs.add_argument("-f", "--files", dest="files_in", required=True, nargs="+",
					help="The files to be binded in the given order. Note that one column of each file should contain the exact same names to extract the information for the same row, but not necessarily in the same order. Columns with the same name will be automatically combined and not duplicated.")

requiredArgs.add_argument("-o", "--output", dest="file_out", required=False,
						  help="The name of the output file.")

parser.add_argument("-i", "--identifier", dest="identifier", required=False, default="identifier",
					help="The column name to identify similar rows. Default: 'identifier'")

parser.add_argument("-v", "--verbose", dest="verbose", required=False, default=None, action="store_true",
					help="If selected, will print information to the console.")

args = parser.parse_args()

# Reading input files ______________________________________________________________________________
if args.verbose:
	print("  Reading files")

out = pd.DataFrame()
first = True
#for filei in args.files_in:
for filei in ("../guinardia/probes_guinardia_PR2_s001_m8.tsv", "../guinardia/probes_guinardia_PR2_s001_m8_tested_m2.tsv", "../guinardia/probes_guinardia_PR2_s001_m8_access.tsv"):
	f = pd.read_csv(filei, sep="\t")
	if first:
		out = f
		first = False
	else:
		#out = pd.merge(out, f, how="left", on=args.identifier)
		out = pd.merge(out, f, how="left", on="identifier", suffixes=("", "_new"))
		out.drop(out.filter(regex='_new$').columns.tolist(), axis=1, inplace=True)


# Exporting final dataframe ________________________________________________________________________
if args.verbose:
	print("  Exporting")

out.to_csv(args.file_out, sep="\t", index=False)


if args.verbose:
	print("Done")
