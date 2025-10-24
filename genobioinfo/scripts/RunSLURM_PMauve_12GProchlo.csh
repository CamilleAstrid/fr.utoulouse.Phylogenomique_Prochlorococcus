#!/bin/bash
#SBATCH --time=02:00:00 #job time limit
#SBATCH -J ProgressiveMauve_12GProclo
#SBATCH -o RunSLURM_ProgressiveMauve_12GProclo.out
#SBATCH -e RunSLURM_ProgressiveMauve_12GProclo.err
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4 #ncpu on the same node
#SBATCH --chdir=/home/<user>/work/Alignement_genomes
#Purge any previous modules
module purge
#Load the application
module load bioinfo/mauve_2.4.0
# My command lines I want to run on the cluster
progressiveMauve --output=ProgressiveMauve/12GC_Prochlorococcus_PMauve.xmfa --output-guide-tree=ProgressiveMauve/12GC_Prochlorococcus_PMauve.ph cat_genomes_prochlo/12GC_Prochlorococcus.gbk
#
