# module load system/R-3.5.1
pdf(file='~/work/Prochlorococcus/images/8.all.ort.group.5-5.50.pdf', paper="a4")

partition <- '~/work/Prochlorococcus/PorthoMCL/8.all.ort.group.1.5-5.50'
partition <- '~/work/Prochlorococcus/PorthoMCL/8.all.ort.group.5-5.50'
i <- 1
partition_list <- c() 
con = file(partition, "r")
while ( TRUE ) {
  line = readLines(con, n = 1)
  if ( length(line) == 0 ) {
    break
  } 
  members <- strsplit(line, "\t", fixed = FALSE, perl = TRUE)
  print(members)
  partition_list[i] <- length(members[[1]])
  #print(partition_list[[i]])
  i <- i + 1
}
close(con)
partition_list
hist(partition_list, nclass=500, xlim=c(1,20))
dev.off()

# percentage de souches qui ont au moins 1 paralogue
#~ nmax = length(partition_list)
#~ 
#~ tab <- array(0, c(nmax,5))
#~ for (i in 1:nmax)
#~ {
#~    tab[i, 1]   <- i
#~    all_strains <- substr(partition_list[[i]],1,4)
#~    tab[i, 2]   <- length(all_strains)
#~    strain_list <- unique(all_strains)
#~    tab[i, 3]   <- length(strain_list)
#~    cum         <- table(all_strains)
#~    tab[i, 4]   <- sum(cum[cum > 1])
#~    paralogs    <- sum(cum[cum > 1])/length(all_strains)
#~    tab[i, 5]   <- round(paralogs, 3)
#~ }
#~ tab
#~ barplot(tab[,5], tab[,1], xlim=c(1, 1000))
#~ hist(tab[,3], nclass=12)
#~ plot(tab[,2], tab[,5])
