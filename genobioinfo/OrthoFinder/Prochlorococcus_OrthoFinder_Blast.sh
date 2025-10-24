#!/bin/bash
#SBATCH -p workq
#SBATCH -t 01:30:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "da$
#SBATCH --cpus-per-task=16

#Warning! By default 128 threads are used on the node. Don't forget to adjust -t and -a  option of orthofinder command and --$

#Load modules
module load devel/Miniconda/Miniconda3
module load bioinfo/OrthoFinder/2.5.5

orthofinder -t 16 -a 16 -X -f ~/work/OrthoFinder/Prochlorococcus -n Problast -S blast
