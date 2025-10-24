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
mauveAligner --output=Mauve/6GC_Prochlorococcus_gbk.mauve_def --permutation-matrix-output=Mauve/6GC_Prochlorococcus_gbk.permutation_matrix --output-guide-tree=Mauve/6GC_Prochlorococcus_gbk.tree --output-alignment=Mauve/6GC_Prochlorococcus_gbk_mauve.xmfa cat_genomes_prochlo/6GC_Prochlorococcus.gbk
#
