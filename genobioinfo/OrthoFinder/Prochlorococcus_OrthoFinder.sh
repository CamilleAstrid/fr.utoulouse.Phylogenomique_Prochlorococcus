#!/bin/bash
#SBATCH -p workq
#SBATCH -t 01:30:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds". 
#SBATCH --cpus-per-task=16

#Warning! By default 128 threads are used on the node. Don't forget to adjust -t and -a  option of orthofinder command and --cpus-per-task option for Slurm.

#Load modules
module load devel/Miniconda/Miniconda3
module load bioinfo/OrthoFinder/2.5.5

orthofinder -t 16 -a 16 -f ~/work/OrthoFinder/Prochlorococcus -X -n Pro
