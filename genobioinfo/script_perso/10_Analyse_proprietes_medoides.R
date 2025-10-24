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

medoids.file <- "~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp.medoids.txt"

medoids <- read.table(medoids.file, sep = "\t", quote = "", col.names=c("Medoid"))

medoids.properties <- left_join(medoids, prochlo.refseq.genomes.clean, by = join_by(Medoid == assembly_accession))

kable(medoids.properties %>% 
  select(c(Medoid, infraspecific_name, assembly_level, scaffold_count)), 
  caption="Table 1 : Propriétés des médoïdes") %>%
  save_kable("~/work/Prochlorococcus/RefSeq/Prochlorococcus_grrasp.medoids.properties.txt")


# Choix des référence en fonction de leur qualité de séquençage

Prochlo.CheckM.file <- "~/work/Prochlorococcus/RefSeq/CheckM_output_folder/quality_report.tsv"
Prochlo.CheckM <- read.table(Prochlo.CheckM.file, sep = "\t", quote = "", header = T, stringsAsFactors = T, skipNul=T)

Prochlo.CheckM <- Prochlo.CheckM %>% 
  mutate(Name=substr(Name, 3,15))

Prochlo.IQ <- Prochlo.CheckM %>% 
  filter(Completeness>99) %>%
  filter(Contamination<0.7)

Prochlo.CheckM.Quality <- Prochlo.IQ %>% 
  mutate(Quality = round(sqrt( (1 - Completeness/100)^2 + (Contamination)^2),  digits = 4 )) %>% 
  arrange(Quality) %>% 
  select(Name, Quality)

Prochlo.CheckM.Quality.file <- "~/work/Prochlorococcus/RefSeq/CheckM_output_folder/Prochlorococcus_Quality.txt"

write.table(Prochlo.CheckM.Quality, file=Prochlo.CheckM.Quality.file, quote = FALSE, sep = "\t", row.names =FALSE, col.names = FALSE)
