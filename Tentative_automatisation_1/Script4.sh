#!/bin/bash
#SBATCH -p workq
#SBATCH -t 02-00:00:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds". 
#SBATCH --cpus-per-task 8

#Load modules
module load bioinfo/Mash/2.3

#Code
if [[ ! -d ~/work/Prochlorococcus/RefSeq/MashProchlo ]]; then
  mkdir ~/work/Prochlorococcus/RefSeq/MashProchlo
fi

size=10000
kmer=16
for entry in $(awk -F "\t" '{if($2>99 && $3<0.8) print $0}' ~/work/Prochlorococcus/RefSeq/CheckM_output_folder/quality_report.tsv | cut -f 1)
do
 genome=$entry.fna
 echo "module load bioinfo/Mash/2.3; mash sketch -s $size -k $kmer ~/work/Prochlorococcus/RefSeq/DNAProchlo/$genome"
done > ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.sh

sarray -J mash -o %j.out -e %j.err -t 01:00:00 ~/work/Prochlorococcus/RefSeq/MashProchlo/mash.sh