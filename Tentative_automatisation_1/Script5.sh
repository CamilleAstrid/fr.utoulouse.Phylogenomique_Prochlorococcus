#!/bin/bash
#SBATCH -p workq
#SBATCH -t 02-00:00:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds". 
#SBATCH --cpus-per-task 8

#Load modules
module load bioinfo/Mash/2.3

#Code
if [[ ! -e ~/work/Prochlorococcus/RefSeq/MashProchlo ]]; then
  mkdir ~/work/Prochlorococcus/RefSeq/MashProchlo
fi

mash paste ~/work/Prochlorococcus/RefSeq/MashProchlo/mash ~/work/Prochlorococcus/RefSeq/DNAProchlo/*.msh