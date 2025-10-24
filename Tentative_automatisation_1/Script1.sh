#!/bin/bash

# Telechargement d’un jeu de donnees
mkdir -p ~/work/Prochlorococcus/RefSeq
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/assembly_summary_refseq.txt -O ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt

# Filtrer les genomes de *Prochlorococcus*
awk -F "\t" '{if($1~/assembly_accession/ || $8~/Prochlorococcus/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt

# Supprimer le # devant `assembly_accession` pour avoir le nom des colonnes.
sed '1s/^.//' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/foo.txt
rm ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt
mv ~/work/Prochlorococcus/RefSeq/foo.txt ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt

# Filtrer les genomes de *Synechococcus*
awk -F "\t" '{if($1~/assembly_accession/ || $8~/Synecho/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
awk -F "\t" '{if($8~/Cyanobium/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt >> ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
awk -F "\t" '{if($8~/Parasynechococcus/) print $0}' ~/work/Prochlorococcus/RefSeq/assembly_summary_refseq.txt >> ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt

sed '1s/^.//' ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/foo.txt
rm ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt
mv ~/work/Prochlorococcus/RefSeq/foo.txt ~/work/Prochlorococcus/RefSeq/Synecho_assembly_summary_refseq.txt

# Proprietes des genomes

module load statistics/R/4.3.0

R --slave <<-EOF

if (!require('tidyverse')) {install.packages('tidyverse')}
33

if (!require('ggplot2')) {install.packages('ggplot2')}
33

library(tidyverse)
library(ggplot2)

prochlo.refseq.genomes.file <- "~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt"
prochlo.refseq.genomes <- read.table(prochlo.refseq.genomes.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

prochlo.refseq.genomes <- prochlo.refseq.genomes %>% 
  mutate(assembly_accession=substr(assembly_accession, 1,13))

## Genome_and_scaffold_size
pdf_file <- '~/work/Prochlorococcus/RefSeq/Genome_and_scaffold_size.pdf'
pdf(file=pdf_file, paper="a4r")

prochlo.refseq.genomes %>%
ggplot(aes(y=genome_size, x=scaffold_count, color=assembly_level)) + 
    geom_point(size=2, alpha=0.5) +
    theme_bw()
dev.off()

## Genome_size
pdf_file <- '~/work/Prochlorococcus/RefSeq/Genome_size_ori.pdf'
pdf(file=pdf_file, paper="a4r")

prochlo.refseq.genomes %>%
  ggplot( aes(x=genome_size, fill=assembly_level)) +
    geom_histogram( binwidth=100000, color="#e9ecef", alpha=0.8) +
    ggtitle("Bin size = 100000 bp") +
    theme_bw() +
    theme(
      plot.title = element_text(size=15)
    )
dev.off()

q()
y

EOF

# Identification des petits genomes
# NR permet de garder la ligne d'en-tete
# NF correspond au nombre de colonne du fichier
awk -F "\t" 'NR==1 {for (i=1; i<=NF; i++) if ($i=="genome_size") col=i; print $0; next} $col < 1000000' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_small_genome.txt

head -n 1 Prochlo_assembly_summary_refseq_small_genome.txt  | sed 's/\t/\n/g' | nl > numero_colonne.txt

awk -F "\t" 'NR==1 {for (i=1; i<=NF; i++) if ($i=="organism_name") col=i; next}; !seen[$col]++ {print $col}' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_small_genome.txt | sort -u > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_small_genome_type.txt

# Nous allons ecarter ces sequences de l’analyse
awk -F "\t" 'NR==1 {for (i=1; i<=NF; i++) if ($i=="genome_size") col=i; print $0; next} $col > 1000000' ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq.txt > ~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_clean_genome.txt

# Tracer le taux G+C `gc_percent` en fonction de la taille des genomes `genome_size`. Qu’observez-vous?
module load statistics/R/4.3.0
R --slave <<-EOF

library(tidyverse)
library(ggplot2)

prochlo.refseq.genomes.clean.file <- "~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_clean_genome.txt"
prochlo.refseq.genomes.clean <- read.table(prochlo.refseq.genomes.clean.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

prochlo.refseq.genomes.clean <- prochlo.refseq.genomes.clean %>% 
  mutate(assembly_accession=substr(assembly_accession, 1,13))

## GC_percent_and_Genome_size
pdf_file <- '~/work/Prochlorococcus/RefSeq/GC_percent_and_Genome_size.pdf'
pdf(file=pdf_file, paper="a4r")

### Tracer la regression lineaire
mod <- lm(gc_percent ~ genome_size, data=prochlo.refseq.genomes.clean)

prochlo.refseq.genomes.clean %>%
ggplot(aes(y=gc_percent, x=genome_size, color=assembly_level)) + 
    geom_point(size=2, alpha=0.5) +
    geom_abline(
        intercept = mod$coefficients[1],
        slope = mod$coefficients[2],
        linewidth = 1,
        colour = "red"
    ) +
    theme_bw()
dev.off()

q()
y

EOF

## Telechargement des fichiers contenant l’ADN des genomes

### Genomes de *Prochlorococcus*

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

ls ~/work/Prochlorococcus/RefSeq/DNAProchlo/*fna | wc -l

## Evaluation de la qualite des genomes avec CheckM
module load devel/Miniconda/Miniconda3
module load bioinfo/CheckM/1.2.2
checkm taxon_list | grep Synechococcus > CheckM_taxon-list_Synechococcus.txt
checkm taxon_list | grep Prochlorococcus > CheckM_taxon-list_Prochlorococcus.txt

module unload bioinfo/CheckM/1.2.2
module unload devel/Miniconda/Miniconda3

mkdir ~/work/Prochlorococcus/script

cp /usr/local/bioinfo/src/CheckM2/example_on_cluster/test_CheckM2-v1.0.2.sh ~/work/Prochlorococcus/script/CheckM2-v1.0.2.sh
