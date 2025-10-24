# Atelier Phylogenomique
# Création d’un jeu de donnees
# @author Yves Quentin
# @author Camille-Astrid Rodrigues
# @date 2025-10-07 modified 2025-10-15

if (!require('tidyverse')) {install.packages('tidyverse', repos='https://mirror.ibcp.fr/pub/CRAN/')}
if (!require('ggplot2')) {install.packages('ggplot2', repos='https://mirror.ibcp.fr/pub/CRAN/')}
if (!require('getopt')) {install.packages('getopt', repos='https://mirror.ibcp.fr/pub/CRAN/')}
if (!require('ggrasp')) {install.packages('ggrasp', repos='https://mirror.ibcp.fr/pub/CRAN/')}
if (!require('kableExtra')) {install.packages('kableExtra', repos='https://mirror.ibcp.fr/pub/CRAN/')}

library(tidyverse)
library(ggplot2)
library(getopt)
library(ggrasp)
library(kableExtra)

