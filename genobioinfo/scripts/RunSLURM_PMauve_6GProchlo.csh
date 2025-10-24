#!/bin/bash
#SBATCH --time=02:00:00 #job time limit
#SBATCH -J Mauve_6GProclo
#SBATCH -o RunSLURM_Mauve_6GProclo.out
#SBATCH -e RunSLURM_Mauve_6GProclo.err
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4 #ncpu on the same node
#SBATCH --chdir=/home/<user>/work/Alignement_genomes
#Purge any previous modules
module purge
#Load the application
module load bioinfo/mauve_2.4.0
# My command lines I want to run on the cluster
progressiveMauve --output=ProgressiveMauve/6GC_Prochlorococcus_PMauve.xmfa cat_genomes_prochlo/6GC_Prochlorococcus.gbk
#
