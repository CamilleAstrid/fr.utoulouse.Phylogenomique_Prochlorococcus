#!/bin/bash
#SBATCH -J OFProSymmsa
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH --cpus-per-task=16

# Don't forget to adjust -t and -a  option of orthofinder command 
# and --cpus-per-task option for Slurm.

#Load modules
module load devel/Miniconda/Miniconda3
module load bioinfo/OrthoFinder/2.5.5

orthofinder -t 16 -a 16 -X -n ProSynmsa -f ~/work/OrthoFinder/Synechococcus -b ~/work/OrthoFinder/Prochlorococcus/OrthoFinder/Results_Pro/WorkingDirectory -M msa
