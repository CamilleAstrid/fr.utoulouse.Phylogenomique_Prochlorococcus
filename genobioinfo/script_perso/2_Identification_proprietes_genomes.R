# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

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
