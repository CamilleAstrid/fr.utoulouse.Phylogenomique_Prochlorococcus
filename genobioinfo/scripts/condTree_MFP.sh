#!/bin/bash
#SBATCH -J ModelFinderMFP
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH -o ModelFinderMFP.out
#SBATCH -e ModelFinderMFP.err
#SBATCH --cpus-per-task=10

module load bioinfo/IQ-TREE/2.2.2.6

iqtree -s ~/work/Kettler/phyloG/alignments.fas -redo -bb 1000 -alrt 1000 -st CODON -nt AUTO -m MFP -pre ~/work/Kettler/phyloG/ModelFinderMFP -redo
