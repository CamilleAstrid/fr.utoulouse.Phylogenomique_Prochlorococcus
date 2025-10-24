#!/bin/bash
#SBATCH -p workq
#SBATCH -t 1-00:00:00
#Load modules
module load bioinfo/ASTRAL/5.7.8

java -Xmx4g -jar $ASTRAL -i ~/work/Kettler/phyloG/alltrees.tree -o ~/work/Kettler/phyloG/Astral/alltrees.tree
