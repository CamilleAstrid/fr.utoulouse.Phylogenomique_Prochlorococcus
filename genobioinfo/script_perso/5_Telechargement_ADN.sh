#!/bin/bash

# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

# Téléchargement des fichiers contenant l’ADN des génomes

# Génomes de Prochlorococcus
suffix=_genomic.fna.gz

if [[ ! -d ~/work/Prochlorococcus/RefSeq/DNAProchlo ]]; then
  mkdir ~/work/Prochlorococcus/RefSeq/DNAProchlo
fi

for ftp_path in $(awk -F "\t" '{if($26>1e+6) print $20}' ~/work/Prochlorococcus/RefSeq/Prochlo"_assembly_summary_refseq.txt")
do
  genome=$(basename -- "$ftp_path")
  echo $genome
  file=~/work/Prochlorococcus/RefSeq/DNAProchlo/$genome$suffix
  if [[ ! -e $file ]] || [[ ! -s $file ]]; then
    wget $ftp_path/$genome$suffix -O $file
  fi
done

rm ~/work/Prochlorococcus/RefSeq/DNAProchlo/ftp_path_genomic.fna.gz
gzip -d ~/work/Prochlorococcus/RefSeq/DNAProchlo/*.gz

# Evaluation de la qualité des génomes avec CheckM
module load devel/Miniconda/Miniconda3
module load bioinfo/CheckM/1.2.2
checkm taxon_list | grep Synechococcus > CheckM_taxon-list_Synechococcus.txt
checkm taxon_list | grep Prochlorococcus > CheckM_taxon-list_Prochlorococcus.txt

module unload bioinfo/CheckM/1.2.2
module unload devel/Miniconda/Miniconda3

mkdir -p ~/work/Prochlorococcus/script

cp script_CheckM2-v1.0.2.sh ~/work/Prochlorococcus/script/CheckM2-v1.0.2.sh

sbatch ~/work/Prochlorococcus/script/CheckM2-v1.0.2.sh

sleep 2

nb_jobs=$(squeue -u "$USER" | wc -l)

while [ "$nb_jobs" -gt 2 ]; do
  sleep 5
  nb_jobs=$(squeue -u "$USER" | wc -l)
done


