# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

library(tidyverse)
library(ggplot2)

prochlo.refseq.genomes.clean.file <- "~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_clean_genome.txt"
prochlo.refseq.genomes.clean <- read.table(prochlo.refseq.genomes.clean.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

prochlo.refseq.genomes.clean <- prochlo.refseq.genomes.clean %>% 
  mutate(assembly_accession=substr(assembly_accession, 1,13))

## GC_percent_and_Genome_size
pdf_file <- '~/work/Prochlorococcus/RefSeq/GC_percent_and_Genome_size.pdf'
pdf(file=pdf_file, paper="a4r")

### Tracer la régression linéaire
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
