#!/bin/bash
#SBATCH -J ModelFinderGYFR4
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH -o ModelFinder.out
#SBATCH -e ModelFinder.err
#SBATCH --cpus-per-task=10

module load bioinfo/IQ-TREE/2.2.2.6

iqtree -s ~/work/Kettler/phyloG/alignments.fas -redo -bb 1000 -alrt 1000 -st CODON -nt AUTO -m GY+F+R4 -pre ~/work/Kettler/phyloG/ModelFinderGYFR4 -redo
