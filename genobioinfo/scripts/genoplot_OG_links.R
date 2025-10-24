# Collect arguments
args <- commandArgs(TRUE)
 cat(paste("nb arg ", length(args), "\n", sep=""))

# Default setting when no arguments passed
if ( length(args) < 2|| length(args) > 7) {
  args <- c("--help")
}

# Help section
if("--help" %in% args) {
  cat("
count paralogy  
	--MCL_file=\"mcl_file\" 
	--pdf_file=\"PDF file\" 
	--min_size=\"minimum size for OG\" 
	--max_size=\"maximum size for OG\" 
	--select_OG=\"display only this OG\"
	--min_paralogs=\"select OG on parlogs frequency\"
	--max_paralogs=\"select OG on parlogs frequency\"
	\n")
   q(save="no")
}
parseArgs <- function(x) strsplit(sub("^--", "", x), "=")
argsDF <- as.data.frame(do.call("rbind", parseArgs(args)))
argsL <- as.list(as.character(argsDF$V2))
names(argsL) <- argsDF$V1

# test arguments #######################################################
if(is.null(argsL$MCL_file)) {
  cat("Error: --MCL_file is null\n\n")
  q(save="no")
} else {
	if ( !file.exists(argsL$MCL_file) ) {
		cat(paste("Error: --MCL_file=",  argsL$MCL_file, " is not found\n\n", sep=""))
		q(save="no")
	}
	#cat(paste("tree=", argsL$tree, "\n", sep=""))
}

if(is.null(argsL$pdf_file)) {
  cat("Error: --pdf_file is null\n\n")
  q(save="no")
}
# optional parameters ################
min_size <- 2
max_size <- 100
min_paralogs <- 0
max_paralogs <- 1
select_OG <- 0

if ( length(argsL$select_OG) > 0 ) {
	select_OG <- as.integer(argsL$select_OG)
} else {
	if( length(argsL$min_size) > 0 ) {
		min_size <- as.integer(argsL$min_size)
	}
	if( length(argsL$max_size) > 0 ) {
		max_size <- as.integer(argsL$max_size)
	}
	if( length(argsL$min_paralogs) > 0 ) {
		min_paralogs <- as.numeric(argsL$min_paralogs)
	}
	if( length(argsL$max_paralogs) > 0 ) {
		max_paralogs <- as.numeric(argsL$max_paralogs)
	}
}

cat(" --select_OG ", select_OG, "\n")
cat(" --min_paralogs ", min_paralogs, "\n")
cat(" --max_paralogs ", max_paralogs, "\n")
cat(" --min_size ", min_size, "\n")
cat(" --max_size ", max_size, "\n")

partition <- argsL$MCL_file
pdf_file <- argsL$pdf_file

########################################################################
#
library(genoPlotR)


### file with MCL partitions
#mcl_parameters <- '8-5.50'
#partition <- paste("~/work/Prochlorococcus/PorthoMCL/8.all.ort.group.",mcl_parameters, sep='')

#pdf_file1 <- paste("genoplot_OG_links_1_", mcl_parameters, ".pdf", sep='')
#pdf_file2 <- paste("genoplot_OG_links_2_", mcl_parameters, ".pdf", sep='')

### genbank_files
prokka_dir <- '~/work/Prochlorococcus/prokka'
genome_list <- c('Aaab', 'Aaag', 'Aaaj', 'Aaaf', 'Aaak', 'Aaae', 'Aaai', 'Aaad', 'Aaaa', 'Aaah', 'Aaal', 'Aaac')
#genome_list <- c('Aaag', 'Aaab', 'Aaaj', 'Aaaf', 'Aaak', 'Aaae')
#~ genome_list <- c('Aaag', 'Aaab')
gbk_list <- list()

########################################################################
# List of Genbankfiles
########################################################################
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
# Read_genbank
########################################################################
dna_segs <- list()
n <- 1
for (gbk_file in gbk_list ) {
  dna_segs[[n]] <-  read_dna_seg_from_genbank(gbk_file)
  n <- n + 1
}
cat(length(dna_segs), ' dna segments read', "\n")

########################################################################
# Create genome pairs
########################################################################
# list of genome pairs
genome_pairs <- c()
n <- 1
imax <- length(genome_list)-1
for (i in 1:imax) {
  j <- i + 1
  genome_pairs[i] <- paste(genome_list[i], '_vs_', genome_list[j], sep= '')
}
genome_pairs

########################################################################
# Read MCL partitions
########################################################################
# list of partitions
partition_list <- list()

# read partition file 
i <- 1
con = file(partition, "r")
while ( TRUE ) {
  line = readLines(con, n = 1)
  if ( length(line) == 0 ) {
    break
  }
  tmplist <- strsplit(line, "\t", fixed = FALSE, perl = TRUE)

  # select partition on size
  if ( length(tmplist[[1]]) >= min_size && length(tmplist[[1]]) < max_size) {
    partition_list[i] <- tmplist
    i <- i + 1
  }
}
close(con)
cat(length(partition_list), ' OGs in ', partition, "\n")

########################################################################
# Select gene pairs from genome pairs
########################################################################

nmax <- length(partition_list)
if ( select_OG > 0 ){
	start_og <- select_OG
	end_og <- select_OG
} else {
	start_og <- 1
	end_og <- nmax
}

# list foreach entity to save
start1 <- list()
end1 <- list()
start2 <- list()
end2 <- list()
color <- list()
interval <- list()

# loop over partions
for (i in start_og:end_og) {
  
  # loop over members of current partiton i
  # start with the first member of the pair (j)
  jmax <- length(partition_list[[i]])-1
  partition_list[[i]] <- sort(gsub("[|]", "", partition_list[[i]]))
  all_strains <- substr(partition_list[[i]],1,4)
  strain_list <- unique(all_strains)
  cum         <- table(all_strains)
  paralogs    <- sum(cum[cum > 1])/length(all_strains)

  if ( paralogs < min_paralogs ) next
  if ( paralogs > max_paralogs ) next
  cat('OG: ', i, length(partition_list[[i]]), length(strain_list), paralogs, "\n")
  if ( select_OG > 0 ) {
	write(file='', partition_list[[i]])
  }

  for ( j in 1:jmax ) {
    # extract genome name and match gene name with proteinid to obtain the gene coordinates
    genomej <- substring(partition_list[[i]][j], 1, 4)
    gj <- grep(genomej, genome_list)
    
    # if genome is not in list skip
    if ( length(gj) == 0 ) next
    
    #cat('j', genomej, gj,"\n")
    proteinidj <- paste('Prokka', partition_list[[i]][j], sep='')
    gene_coordinatesj <- dna_segs[[gj]][grep(proteinidj, dna_segs[[gj]]$proteinid),c(1:3)]
    #cat('j', genomej, proteinidj, "\n")
    #cat('j', j, partition_list[[i]][j], "\n")
    
    if ( length(gene_coordinatesj[[1]]) > 0 ) {
      
      # loop over second member of the pair (k)
      kmin <- j+1
      kmax <- length(partition_list[[i]])
      for ( k in kmin:kmax ) {
        genomek <- substring(partition_list[[i]][k], 1, 4)
        gk <- grep(genomek, genome_list)
        if ( length(gk) == 0 ) next
        
        proteinidk <- paste('Prokka', partition_list[[i]][k], sep='')
        gene_coordinatesk <- dna_segs[[gk]][grep(proteinidk, dna_segs[[gk]]$proteinid),c(1:4)]
        #cat('j', j, partition_list[[i]][j], 'k', k, partition_list[[i]][k], "\n")
        if ( length(gene_coordinatesk[[1]]) > 0 ) {
          proteinid1 <- ''
          proteinid2 <- ''
          pair <- paste(genomej, '_vs_', genomek, sep= '')
          # test if query vs hit is in selected pairs
          if ( length(grep(pair, genome_pairs)) > 0 ) {
            proteinid1 <- proteinidj
            proteinid2 <- proteinidk
            genome1 <- genomej
            genome2 <- genomek
            gene_coordinates1 <- gene_coordinatesj
            gene_coordinates2 <- gene_coordinatesk
         } else {
            pair <- paste(genomek, '_vs_', genomej, sep= '')
            if ( length(grep(pair, genome_pairs)) > 0 ) {
              proteinid1 <- proteinidk
              proteinid2 <- proteinidj
             genome1 <- genomek
             genome2 <- genomej
              gene_coordinates1 <- gene_coordinatesk
              gene_coordinates2 <- gene_coordinatesj
           }
          }
            
          # genes belong to selected genome pair
          if ( proteinid1 != '' && proteinid2 != '' ) {
            # test if the genes coordinates were found!
        
            #cat('true 1 ', ortho_pairs[i,1], '', ortho_pairs[i,2], '', ortho_pairs[i,3], "\n")
            k <- length(start1[[pair]])+1
            start1[[pair]][[k]] <- gene_coordinates1[1,2]
            end1[[pair]][[k]]   <- gene_coordinates1[1,3]
            start2[[pair]][[k]] <- gene_coordinates2[1,2]
            end2[[pair]][[k]]   <- gene_coordinates2[1,3]
            
            # if only on OG is tested 
            if ( start_og == end_og ) {
             #cat(pair, 'j', j, partition_list[[i]][j], 'k', k, partition_list[[i]][k], "\n")
             if ( length(interval[[genome1]]) > 0) {
                interval[[genome1]][[1]] <- min(interval[[genome1]][[1]], gene_coordinates1[1,2], gene_coordinates1[1,3])
                interval[[genome1]][[2]] <- max(interval[[genome1]][[2]], gene_coordinates1[1,2], gene_coordinates1[1,3])
              } else {
                interval[[genome1]][[1]] <- min(gene_coordinates1[1,2], gene_coordinates1[1,3])
                interval[[genome1]][[2]] <- max(gene_coordinates1[1,2], gene_coordinates1[1,3])
              }
              if ( length(interval[[genome2]]) > 0) {
                interval[[genome2]][[1]] <- min(interval[[genome2]][[1]], gene_coordinates2[1,2], gene_coordinates2[1,3])
                interval[[genome2]][[2]] <- max(interval[[genome2]][[2]], gene_coordinates2[1,2], gene_coordinates2[1,3])
              } else {
                interval[[genome2]][[1]] <- min(gene_coordinates2[1,2], gene_coordinates2[1,3])
                interval[[genome2]][[2]] <- max(gene_coordinates2[1,2], gene_coordinates2[1,3])
              }
            }
          }
        }
      }
    }
  }
}
#interval

########################################################################
# Genome interval
########################################################################

xlim_list <- list()
if ( length(interval) > 0 ){
  i <- 1
  for (genome in genome_list ) {
    xlim_list[i] <- list(interval[[genome]])
    i <- i + 1
  }
} else {
  for (i in 1:length(genome_list)) {
    xlim_list[i] <- list(c(1, 50000))
  }
}
xlim_list
########################################################################


########################################################################
# Create comparison list
########################################################################

all_comparisons <- list()
for (pair in genome_pairs) {
  cat(pair, "\n", sep='')
  dframe <-data.frame(cbind(start1[[pair]], end1[[pair]], start2[[pair]], end2[[pair]]))
  names(dframe) <- c('start1', 'end1', 'start2', 'end2')
  all_comparisons[[pair]] <- comparison(dframe)
}
comparison(head(dframe))
length(all_comparisons)


########################################################################
# Plot genomes
########################################################################
#~ pdf(file=pdf_file, paper="a4r")
#~ plot_gene_map(
#~   seg_plot_height=3,
#~   xlims=xlim_list,
#~   dna_segs=dna_segs,
#~   comparison=all_comparisons,
#~   main=" Prochlorococcus",
#~   gene_type="side_blocks",
#~   dna_seg_scale=TRUE, scale=FALSE)
#~ dev.off()
#~ cat(pdf_file1, "\n")
########################################################################

########################################################################
pdf(file=pdf_file, paper="a4r")
plot_gene_map(
  seg_plot_height=3,
  dna_segs=dna_segs,
  comparison=all_comparisons,
  main=" Prochlorococcus strains (OG links)",
  gene_type="side_blocks",
  dna_seg_scale=TRUE, scale=FALSE)
########################################################################
dev.off()
cat(pdf_file, "\n")
