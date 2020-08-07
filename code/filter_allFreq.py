import sys

if len(sys.argv)==1 or sys.argv[1].startswith('-h'):
	print("\nScript written for snakemake pipeline for detection of sex-linked genomic regions. WARNING: USE WITH CAUTION OUTSIDE PIPELINE.\n")

	print("Filters an allele frequency file generated by \'vcftools --freq\' and keeps sites that have a frequency between 0.4 and 0.6.")
	print("Prints to stdout.\n")

	print("Call:\tpython3 {python-script} {allele frequency-file} {sex}\n")
	sys.exit()
elif not len(sys.argv)==3:
	print("\nERROR: wrong number of input arguments!\n")

	print("Call:\tpython3 {python-script} {allele frequency-file} {sex}\n")
	sys.exit()


sex = sys.argv[2]

with open(sys.argv[1], 'r') as allFreq:

	for line in allFreq:

		if not line.startswith('CHROM\tPOS'):

			fields = line.split('\t')
			frequency = float(fields[4].split(':')[1])

			if frequency < 0.6 and frequency > 0.4:

				sys.stdout.write('\t'.join([fields[0], fields[1], str(int(fields[1]) + 1), sex]) + '\n')


