#!/bin/bash
#SBATCH -p workq
#SBATCH -t 02-00:00:00 #Acceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds". 
#SBATCH --cpus-per-task 8

#Need Miniconda
module load devel/Miniconda/Miniconda3

module load bioinfo/CheckM2/1.0.2

checkm2 predict --threads 8 -i ~/work/Prochlorococcus/RefSeq/DNAProchlo  -o ~/work/Prochlorococcus/RefSeq/CheckM_output_folder --database_path /usr/local/bioinfo/src/CheckM2/CheckM2-v1.0.2/databases/CheckM2_database/uniref100.KO.1.dmnd --force

