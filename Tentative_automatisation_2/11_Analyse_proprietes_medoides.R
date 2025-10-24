# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

# Proprietes des medoides

library(kableExtra)
library(tidyverse)
library(ggplot2)

prochlo.refseq.genomes.clean.file <- "~/work/Prochlorococcus/RefSeq/Prochlo_assembly_summary_refseq_clean_genome.txt"
prochlo.refseq.genomes.clean <- read.table(prochlo.refseq.genomes.clean.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)
prochlo.refseq.genomes.clean <- prochlo.refseq.genomes.clean %>% 
  mutate(assembly_accession=substr(assembly_accession, 3,15))
  
medoids.file <- "~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_grraspQ.medoids.txt"
medoids <- read.table(medoids.file, sep = "\t", quote = "", col.names=c("Medoid"))

medoids.properties <- left_join(medoids, prochlo.refseq.genomes.clean, by = join_by(Medoid == assembly_accession))
table <- kable(medoids.properties %>% 
  select(c(Medoid, infraspecific_name, assembly_level, scaffold_count)), 
      caption="Table 2 : Propriétés des médoïdes filtrés en fonction de leur qualité de séquençage")
table %>%
    save_kable("~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp.medoids.properties.quality-sort.txt")
