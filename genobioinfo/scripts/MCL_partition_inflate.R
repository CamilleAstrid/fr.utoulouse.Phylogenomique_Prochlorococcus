# Collect arguments
library(stringr)

args <- commandArgs(TRUE)
 cat(paste("nb arg ", length(args), "\n", sep=""))

# Default setting when no arguments passed
if ( length(args) < 2|| length(args) > 3) {
  args <- c("--help")
}

# Help section
if("--help" %in% args) {
  cat("
count paralogy  
	--MCL_dir=\"directory path with mcl_files\" 
	--nb_strains=\"number of strains\" 
	--pdf_file=\"PDF file\" 
	\n")
   q(save="no")
}
parseArgs <- function(x) strsplit(sub("^--", "", x), "=")
argsDF <- as.data.frame(do.call("rbind", parseArgs(args)))
argsL <- as.list(as.character(argsDF$V2))
names(argsL) <- argsDF$V1

# test arguments #######################################################
if(is.null(argsL$MCL_dir)) {
  cat("Error: --MCL_dir is null\n\n")
  q(save="no")
} else {
	if ( !file.exists(argsL$MCL_dir) ) {
		cat(paste("Error: --MCL_dir=",  argsL$MCL_dir, " is not found\n\n", sep=""))
		q(save="no")
	}
	#cat(paste("tree=", argsL$tree, "\n", sep=""))
}

if(is.null(argsL$nb_strains)) {
  cat("Error: --nb_strains is null\n\n")
  q(save="no")
} else {
  nb_strains <- as.integer(argsL$nb_strains)
}
if(is.null(argsL$pdf_file)) {
  cat("Error: --pdf_file is null\n\n")
  q(save="no")
}
pdf_file <- argsL$pdf_file

########################################################################
#
#library(genoPlotR)
MCL_dir <- argsL$MCL_dir
mcl_files <- list.files(path=MCL_dir, pattern='group', full.names = T)
#mcl_files

mat <- matrix(c(0), nrow=length(mcl_files), ncol=5)
colnames(mat) <- c('IF', 'nu', 'nopara', 'core', '>12')
k <- 1
for ( partition in mcl_files) {
	cat('read ', partition, "\n")
	inflate <- str_match(partition, 'group.([0-9].*[0-9]*)-')
	cat(inflate[2], "\n")
	if ( length(inflate) == 2 ) {
		mat[k, 1] <- as.numeric(inflate[2])
	} else {
		mat[k, 1] <- k
	}
	i <- 1
	partition_list <- list() 
	con = file(partition, "r")
	while ( TRUE ) {
	  line = readLines(con, n = 1)
	  if ( length(line) == 0 ) {
		break
	  }    
	  partition_list[i] <- (strsplit(line, "\t", fixed = FALSE, perl = TRUE))
	  i <- i + 1
	}
	close(con)
	
	# percentage de souches qui ont au moins 1 paralogue
	nmax = length(partition_list)
	mat[k, 2] = nmax
	for (i in 1:nmax) {
	   all_strains <- substr(partition_list[[i]],1,4)
	   strain_list <- unique(all_strains)
	   cum         <- table(all_strains)
	   paralogs    <- sum(cum[cum > 1])/length(all_strains)
		if ( paralogs == 0 ) {
			mat[k, 3] = mat[k, 3]+1
		}
		if ( length(strain_list) == nb_strains ) {
			mat[k, 4] = mat[k, 4]+1
		}
		if ( length(all_strains) > nb_strains ) {
			mat[k, 5] = mat[k, 5]+1
		}
	}
	cat(mat[k, 1], mat[k, 2], mat[k, 3], mat[k, 4], "\n")
	k <- k+1
}
mat
ymin <- min(mat[,2], mat[,3], mat[,4], mat[,5])
ymax <- max(mat[,2], mat[,3], mat[,4], mat[,5])
pdf(file=pdf_file, paper="a4r")
plot(mat[,c(1,2)], type="l", col="blue", xlab='inflate', ylab='#members', ylim=c(ymin, ymax))
points(mat[,c(1,3)], type="l", col="red")
points(mat[,c(1,4)], type="l", col="green")
points(mat[,c(1,5)], type="l", col="orange")
dev.off()
cat(pdf_file, "\n")
