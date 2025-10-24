#!/bin/bash

# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

# Analyse des petits genomes et leur retrait

# NR permet de garder la ligne d'en-tête
# NF correspond au nombre de colonne du fichier
awk -F "\t" 'NR==1 {for (i=1; i<=NF; i++) if ($i=="genome_size") col=i; print $0; next} $col < 1000000' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_small_genome.txt

# Recuperation des noms de colonnes et de leur numéro
head -n 1 Prochlo_assembly_summary_refseq_small_genome.txt  | sed 's/\t/\n/g' | nl > numero_colonne.txt

# Analyse des petits genomes
awk -F "\t" 'NR==1 {for (i=1; i<=NF; i++) if ($i=="organism_name") col=i; next}; !seen[$col]++ {print $col}' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_small_genome.txt | sort -u > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_small_genome_type.txt

# Retrait des petits genomes
awk -F "\t" 'NR==1 {for (i=1; i<=NF; i++) if ($i=="genome_size") col=i; print $0; next} $col > 1000000' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_clean_genome.txt

