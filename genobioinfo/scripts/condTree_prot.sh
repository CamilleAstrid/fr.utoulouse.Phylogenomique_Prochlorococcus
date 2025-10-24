#!/bin/bash
#SBATCH -J ModelFinderProt
#SBATCH -p workq
#SBATCH -t 01-00:00:00  
#SBATCH -o ModelFinderProt.out
#SBATCH -e ModelFinderProt.err
#SBATCH --cpus-per-task=10

module load bioinfo/IQ-TREE/2.2.2.6

iqtree -s ~/work/Kettler/phyloG/PEPalignments.fas -B 1000 -alrt 1000 -nt AUTO -mset WAG,LG,JTT -madd LG4M,LG4X -mrate E,I,G,I+G,R -pre ~/work/Kettler/phyloG/ModelFinderProt -redo
