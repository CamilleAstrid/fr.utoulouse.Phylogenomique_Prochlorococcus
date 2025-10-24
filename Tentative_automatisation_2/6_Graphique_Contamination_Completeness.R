# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

# Creation du graphique Contamination_vs_Contamination

library(tidyverse)
library(ggplot2)

Prochlo.CheckM.file <- "~/work/Prochlorococcus/RefSeq/CheckM_output_folder/quality_report.tsv"
Prochlo.CheckM <- read.table(Prochlo.CheckM.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

## Contamination vs Contamination
pdf_file <- '~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Contamination_vs_Contamination.pdf'
pdf(file=pdf_file, paper="a4r")

Prochlo.CheckM %>%
ggplot(aes(y=Contamination, x=Completeness, col="coral")) + 
    geom_point(size=2, alpha=0.5) +
    geom_vline(xintercept=99, col="purple", alpha=0.5) + 
    geom_hline(yintercept=0.7, col="purple", alpha=0.5) + 
    theme_bw()

dev.off()
