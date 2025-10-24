pangenome_size <- 'results/pangenome_size'
pdf_file <- '~/work/Prochlorococcus/images//newgenome.pdf'

z <- read.table(file=pangenome_size, header=T)
head(z)

znox<-z[,"Genome"]
min_genomes <- min(znox)
max_genomes <- max(znox)
znoy<-z[,"Novel"]
min_novel <- min(znoy)
max_novel <- max(znoy)
ymed <- vector(mode="numeric", length=0)
xmed <- vector(mode="integer", length=0)
for (i in min_genomes:max_genomes) {
    ymed <- c(ymed, median(z[,"Novel"][z[,"Genome"]==i]))
    xmed <- c(xmed, i)
}

print("Novel Genes : Power Model: Medians")
nov_pwmed_nlsfit<-nls(ymed~k*xmed^(-a), start=list(k=min_genomes*max(ymed),a=1),trace=TRUE,control = nls.control(warnOnly=T, minFactor =0))
summary(nov_pwmed_nlsfit)
coef_est <- coef(summary(nov_pwmed_nlsfit))

maxXlim <- 4 * max_genomes
minYlim <- min_novel
if (minYlim < 1) { #for log-log plots cannot have this less than 1
    minYlim <- 1
}
maxYlim <- max_novel

pdf(file=pdf_file, paper="a4r")
plot (znoy ~ znox, xlim=c(2,maxXlim), ylim=c(minYlim,maxYlim), log="xy", col="gray", lend="square", main="Novel Genes Medians: Power Red", xlab="# of genomes", ylab="# of new genes", pch=1, cex=0.25)
points(xmed, ymed, col="purple", pch=1, cex=0.5)
label <- paste("a=",round(coef_est[2,1], d=2),"+/-", round(coef_est[2,2], d=2), sep='')
text(30,80,, labels = label)
xf<-seq(from=1, to=maxXlim, by=1)
xf
dxfmed <- data.frame(xmed=xf)
lines(xf, predict(nov_pwmed_nlsfit, dxfmed), col="red", lwd=1)

dev.off()
cat(pdf_file, "\n")
