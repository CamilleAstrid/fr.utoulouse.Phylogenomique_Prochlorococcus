pangenome_size <- 'results/pangenome_size_comp'
pdf_file <- '~/work/Prochlorococcus/images/pangenome.pdf'

data <- read.table(file=pangenome_size, header=T)
head(data)

znox<-data[,"Genome"]
min_genomes <- min(znox)
max_genomes <- max(znox)

# calculer les médianes pour chaque taille d'échantillon
# pan_genome 
cat("\npan_genome: calculer les médianes\n")
ymedpg <- vector(mode="numeric", length=0)
xmedpg <- vector(mode="integer", length=0)
for (i in min_genomes:max_genomes) {
    ymedpg <- c(ymedpg, median(data[,"Pan_genome"][data[,"Genome"]==i]))
    xmedpg <- c(xmedpg, i)
}
# estimation des paramètres k et a
cat("\nestimation des paramètres k et a\n")
kapg<-nls(ymedpg~k*xmedpg^(-a), start=list(k=min_genomes*max(ymedpg),a=1),trace=TRUE,control = nls.control(warnOnly=T, minFactor =0))
coef(kapg)

# gènes coeurs 
cat("\ngènes coeurs: calculer les médianes\n")
ymedcg <- vector(mode="numeric", length=0)
xmedcg <- vector(mode="integer", length=0)
for (i in min_genomes:max_genomes) {
    ymedcg <- c(ymedcg, median(data[,"Core"][data[,"Genome"]==i]))
    xmedcg <- c(xmedcg, i)
}
# estimation des paramètres k et a
cat("\nestimation des paramètres k et a\n")
kacg<-nls(ymedcg~k*xmedcg^(-a), start=list(k=min_genomes*max(ymedcg),a=1),trace=TRUE,control = nls.control(warnOnly=T, minFactor =0))
coef(kacg)

ymax <- max(data$Genome, data$Pan_genome)
ymin <- 0

pdf(file=pdf_file, paper="a4r")
plot(data[,"Genome"], data[,"Pan_genome"], col='grey',xlim=c(min_genomes, max_genomes), xlab='Number of genomes', ylab='Number of genes', ylim=c(ymin, ymax), pch=15)
points(xmedpg, ymedpg, col="blue", pch=17, cex=1)
xf<-seq(from=min_genomes, to=max_genomes, by=1)
dxfmedpg <- data.frame(xmed=xf)
lines(xf, predict(kapg, dxfmedpg), col="blue", lwd=1.5)

points(data$Genome, data$Core, col='grey', pch=15)
points(xmedcg, ymedcg, col="green", pch=16, cex=1)
dxfmedcg <- data.frame(xmed=xf)
lines(xf, predict(kacg, dxfmedcg), col="green", lwd=1.5)
dev.off()
cat(pdf_file, "\n")
