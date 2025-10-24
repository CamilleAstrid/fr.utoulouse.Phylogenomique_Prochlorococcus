#!/bin/bash
#SBATCH -J ModelFinderCodon
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH -o ModelFinderCodon.out
#SBATCH -e ModelFinderCodon.err
#SBATCH --cpus-per-task=1

module load bioinfo/IQ-TREE/2.2.2.6
iqtree -s ~/work/Kettler/phyloG/alignments.fas -redo -st CODON -nt AUTO -m TESTONLY
