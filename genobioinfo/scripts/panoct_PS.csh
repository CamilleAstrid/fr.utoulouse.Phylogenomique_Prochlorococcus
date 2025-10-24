#!/bin/bash
#SBATCH --time=02:00:00 #job time limit
#SBATCH -J panoct_PS
#SBATCH -o panoct_PS.out
#SBATCH -e panoct_PS.err
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4 #ncpu on the same node
#SBATCH --chdir=/home/<user>/work/ProchlorococcusSynechococcus/panoct
#SBATCH --mail-type=BEGIN,END,FAIL (email address is LDAP accounts)
#Purge any previous modules
module purge
#Load the application
# My command lines I want to run on the cluster
/home/formation/public_html/M2_Phylogenomique/PanGenomePipeline/PanGenomePipeline-master/pangenome/bin/panoct.pl -b results -t combined.blast -f genomes.list -g combined.att -P combined.fasta -S yes -L 1 -M Y -H Y -V Y -N Y -F 1.33 -G y -c 0,50,95,100 -T
#
