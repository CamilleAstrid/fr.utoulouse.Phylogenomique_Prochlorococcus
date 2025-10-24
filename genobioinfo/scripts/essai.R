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
reroot tree with a list of OTUs  
	--tree=\"tree file\" 
	--pdf=\"PDF file\" 
	\n")
#~   q(save="no")
}
directory <- '/home/yquentin/work/Prochlorococcus/PorthoMCL/4.splitSimSeq'
filenames <- list.files(directory, pattern = "*..ss.tsv*", full.names = TRUE)
nbfile <- length(filenames)


allintra <- NULL
for (i in 1:nbfile){ 
	cat(filenames[i], "\n")
	data <- read.table(filenames[i], header=F, stringsAsFactors = FALSE)
	intra <- subset(data, data[,1]!=data[,2])
	allintra <- rbind(allintra, intra)
}
nrow(allintra)

png(pdffile, width = 480, height = 480, units = "px", pointsize = 12, bg = "white")
hist(allintra$V5, nclass=50, xlim=c(0,100), xlab='percentMatch', col='lightblue', freq=F)
hist(allintra$V4, nclass=200, xlim=c(-20,0), xlab='evalueExponent', col='lightblue', freq=F)
plot(allintra$V4, allintra$V5)
dev.off()


files <- as.character(list.files(path=directory))
directory <- "C://temp"  ## for example
filenames <- list.files(directory, pattern = "*.*", full.names = TRUE)
readLines(paste("[file path]",.Platform$file.sep,files[1],sep=""))


file <- '/home/yquentin/work/Prochlorococcus/PorthoMCL/4.splitSimSeq/Aaaa.ss.tsv'
pdffile <- 'essai.png'

data <- read.table(file, header=F)

png(pdffile, width = 480, height = 480, units = "px", pointsize = 12, bg = "white")
hist(data$V5, nclass=50, xlim=c(0,100), xlab='identity')
dev.off()


ifelse(dat$Genotype==dat$S288C,1,ifelse(dat$Genotype==dat$SK1,0,NA))

subset(data, data[,1]!=data[,2])

subset(data, factor(data$V1)!=factor(data$V2))






partition <- '/home/yquentin/work/Prochlorococcus/PorthoMCL/8.all.ort.group.5.50'
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
tab
barplot(tab[,5], tab[,1], xlim=c(1, 1000))
hist(tab[,3], nclass=12)
plot(tab[,2], tab[,5])
