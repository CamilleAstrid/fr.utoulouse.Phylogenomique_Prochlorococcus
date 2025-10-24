#!/bin/bash

# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

# Recuperation des Prochlorococcus RefSeq au NCBI
mkdir -p ~/work/Prochlorococcus/RefSeq
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/assembly_summary_refseq.txt -O ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt

# Filtrer les genomes de Prochlorococcus
awk -F "\t" '{if($1~/assembly_accession/ || $8~/Prochlorococcus/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt

# Filtrer les genomes de Synechococcus
awk -F "\t" '{if($1~/assembly_accession/ || $8~/Synecho/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
awk -F "\t" '{if($8~/Cyanobium/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt >> ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
awk -F "\t" '{if($8~/Parasynechococcus/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt >> ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt

# Supprimer le # devant `assembly_accession` pour obtenir le header
sed '1s/^.//' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/foo.txt
rm ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt
mv ~/work/Prochlorococcus/RefSeq/foo.txt ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt
sed '1s/^.//' ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/foo.txt
rm ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
mv ~/work/Prochlorococcus/RefSeq/foo.txt ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
