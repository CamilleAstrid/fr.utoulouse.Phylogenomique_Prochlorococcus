
#
library(genoPlotR)


prokka_dir <- '~/work/Prochlorococcus/prokka'
blastn_dir <- '~/work/Prochlorococcus/BlastN'
genome_list <- c('Aaab', 'Aaag', 'Aaaj', 'Aaaf', 'Aaak', 'Aaae', 'Aaai', 'Aaad', 'Aaaa', 'Aaah', 'Aaal', 'Aaac')
pdf_file <- "~/work/Prochlorococcus/images/genoplot_blastn_links.pdf"

########################################################################
# List genbank files
########################################################################
gbk_list <- list()
n <- 1
for (genome in genome_list ) {
  gbk_file <- paste(prokka_dir, '/', genome, '/', genome, '.gbk', sep= '')
  if ( !file.exists(gbk_file) ) {
    cat('ERROR: file ', gbk_file, ' is not found')
  } else {
    gbk_list[[n]] <- gbk_file
    n <- n + 1
  }
}
cat(length(gbk_list), ' gbk files', "\n")

########################################################################
# List blastn files
########################################################################
blt_list <- list()
n <- 1
imax <- length(gbk_list)-1
for (i in 1:imax) {
  j <- i + 1
  blt_file <- paste(blastn_dir, '/', genome_list[i], '_vs_', genome_list[j], '.tab', sep= '')
  if ( !file.exists(blt_file) ) {
    cat('ERROR: file ', blt_file, ' is not found')
  } else {
    blt_list[[n]] <- blt_file
    n <- n + 1
  }
}
cat(length(blt_list), ' blast files', "\n")

########################################################################
# Read Genbank files
########################################################################
dna_segs <- list()
n <- 1
for (gbk_file in gbk_list ) {
  dna_segs[[n]] <-  read_dna_seg_from_genbank(gbk_file)
  n <- n + 1
}
cat(length(dna_segs), ' dna segments read', "\n")


########################################################################
# Read blastn files
########################################################################
compa <- list()
n <- 1
for (blt_file in blt_list ) {
  compa[[n]] <- read_comparison_from_blast(blt_file)
  n <- n + 1
}
cat(length(compa), ' blast results read', "\n")

########################################################################
# Plot genome comparison
########################################################################
pdf(file=pdf_file, paper="a4r")
plot_gene_map(
  seg_plot_height=3,
  dna_segs=dna_segs,
  comparison=compa,
  main=" Prochlorococcus strains",
  gene_type="side_blocks",
  dna_seg_scale=TRUE, scale=FALSE)
  
dev.off()
cat(pdf_file, "\n")

