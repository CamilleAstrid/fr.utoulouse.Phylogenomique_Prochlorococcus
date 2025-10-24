# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

# Trace des résultats

library(tidyverse)
library(ggplot2)

Prochlo.Mash.file <- "~/work/Prochlorococcus/RefSeq/MashProchlo/mashProchlo.txt"
Mash.colnames <- c("Query", "Hit", "Distance", "Pvalue", "Ratio")
Prochlo.Mash <- read.table(Prochlo.Mash.file, sep = "\t", quote = "", header = F, col.names=Mash.colnames, stringsAsFactors = T, skipNul=T)

# Mash_id_distribution
pdf_file <- '~/work/Prochlorococcus/RefSeq/MashProchlo/Mash_id_distribution.pdf'
pdf(file=pdf_file, paper="a4r")

Prochlo.Mash %>%
  ggplot( aes(x=(1-Distance)*100)) +
    geom_histogram(binwidth=1, fill="coral", col="coral", alpha=0.8) +
    ggtitle("Bin size = 1 %") +
    geom_vline(xintercept=95, col="red", alpha=0.5) + 
    theme_bw() +
    theme(
      plot.title = element_text(size=15)
    )
dev.off()

# Matrix
Prochlo.Mash.matrix <- Prochlo.Mash %>% 
  mutate(Query=substr(Query,55, 67)) %>% 
  mutate(Hit=substr(Hit,55, 67)) %>% 
  pivot_wider(id_cols=Query, names_from=Hit, values_from = "Distance")

Prochlo.Mash.matrix.file <- "~/work/Prochlorococcus/RefSeq/MashProchlo/Prochlo.Mash.matrix.txt"

write.table(Prochlo.Mash.matrix, file=Prochlo.Mash.matrix.file, quote = FALSE, sep = "\t", row.names =FALSE, col.names = TRUE)

