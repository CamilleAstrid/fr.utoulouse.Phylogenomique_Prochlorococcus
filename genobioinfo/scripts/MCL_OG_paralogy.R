# Collect arguments
args <- commandArgs(TRUE)
 cat(paste("nb arg ", length(args), "\n", sep=""))

# Default setting when no arguments passed
if ( length(args) < 2|| length(args) > 2) {
  args <- c("--help")
}

# Help section
if("--help" %in% args) {
  cat("
count paralogy  
	--MCL_file=\"mcl_file\" 
	--pdf_file=\"PDF file\" 
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
partition <- argsL$MCL_file

########################################################################
i <- 1
partition_list <- list() 
con = file(partition, "r")
while ( TRUE ) {
  line = readLines(con, n = 1)
  if ( length(line) == 0 ) {
    break
  }    
  partition_list[i] <- (strsplit(line, "\t", fixed = FALSE, perl = TRUE))
  #print(partition_list[[i]])
  i <- i + 1
}
close(con)

# percentage de souches qui ont au moins 1 paralogue
nmax = length(partition_list)

tab <- array(0, c(nmax,5))
for (i in 1:nmax)
{
   tab[i, 1]   <- i
   all_strains <- substr(partition_list[[i]],1,4)
   tab[i, 2]   <- length(all_strains)
   strain_list <- unique(all_strains)
   tab[i, 3]   <- length(strain_list)
   cum         <- table(all_strains)
   tab[i, 4]   <- sum(cum[cum > 1])
   paralogs    <- sum(cum[cum > 1])/length(all_strains)
   tab[i, 5]   <- round(paralogs, 3)
}
colnames(tab) <- c('num', 'genes', 'strains', 'cum', 'paralogs')
tab <- tab[tab[, 5]>0,]
tab

cat('last column: percentage of strains with at least one paralog', "\n")
pdf(file=argsL$pdf_file, paper="a4r")

#~ barplot(tab[,5], tab[,1], xlim=c(1, 1000))
hist(tab[,5], nclass=12, xlab='frequency of strains with at least one paralog', xlim=c(0,1), ylim=c(0,100))
#~ plot(tab[,2], tab[,5])
dev.off()
cat(argsL$pdf_file, "\n")
