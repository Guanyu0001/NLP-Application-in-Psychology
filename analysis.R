if (!require(bibliometrix)) install.packages("bibliometrix")
library(stringr)
library(ggplot2)
load("wos_final.RData")
load("psycinfo_final.RData")
load("pubmed_final.RData")


# 0 limit to 30 years -----------------------------------------------------

rayyan <- convert2df(file = "rayyan_combined_revised.bib", dbsource =, format = "bibtex")
rayyan_30 <- rayyan[rayyan$PY!=2021&rayyan$PY!=1990,]
sum(is.na(rayyan_30$url))

# plot
ggplot(data = rayyan_30, aes(x=PY))+
    geom_histogram(fill = "white", colour = "black")+
    stat_bin( geom='text', aes(label=..count..),size =3, vjust = -0.5)+
    ylab("Number of Publications")+
    xlab("Publication Year")+
    scale_x_continuous(breaks = c(1990,1995,2000,2005,2010,2015,2020))



wos_final <- wos_final[wos_final$PY!=2021&wos_final$PY!=1990,]
pubmed_final <- pubmed_final[pubmed_final$PY!=2021&pubmed_final$PY!=1990,]
psycinfo_final <- psycinfo_final[psycinfo_final$PY!=2021&psycinfo_final$PY!=1990,]



results_wos <- biblioAnalysis(wos_final, sep = ";")
results_psycinfo <- biblioAnalysis(psycinfo_final, sep = ";")
results_pubmed<- biblioAnalysis(pubmed_final, sep = ";")

results_rayyan <-  biblioAnalysis(rayyan_30, sep = ";")
# 1 main results ----------------------------------------------------------


options(width=100)
summary(object = results_wos, k = 10, pause = FALSE)
summary(object = results_psycinfo, k = 10, pause = FALSE)
summary(object = results_pubmed, k = 10, pause = FALSE)

summary(object = results_rayyan, k = 10, pause = FALSE)
sum(is.na(rayyan_30$AU))

# Average years from publication        5.36 
sum(na.omit(2021-rayyan_30$PY))/2498

#Annual Percentage Growth Rate 18.70279 
(((433)/3)^(1/29)-1)*100


results_wos[["Sources"]]#titles of the journal

plot(x = results_wos, k = 10, pause = FALSE)
plot(x = results_psycinfo, k = 10, pause = FALSE)
plot(x = results_pubmed, k = 10, pause = FALSE)

plot(x = results_rayyan, k = 10, pause = FALSE)

# 2 co-citation -----------------------------------------------------------

CRF <- citations(wos_final, field = "article", sep = ";")
cbind(CRF$Cited[1:10])
CRF <- citations(wos_final, field = "author", sep = ";")
cbind(CRF$Cited[1:10])


CRL <- localCitations(wos_final, sep = ";")
CRL$Authors[1:10,]
CRL$Papers[1:10,]

Hindex(wos_final, field = "author", elements="PENNEBAKER JW", sep = ";", years = 20)


authors=gsub(","," ",names(results_wos$Authors))
indices<- Hindex(wos_final, field = "author", elements=authors, sep = ";", years = 20)
indices$H[order(indices$H$h_index,decreasing = T),][1:10,]


# 3 network ---------------------------------------------------------------
##################
####The Basics####
##################
#to create a network Manuscript x Publication Source you have to use the field tag “SO”:
wos_network <- cocMatrix(wos_final, Field = "SO", sep = ";")
sort(Matrix::colSums(wos_network), decreasing = TRUE)[1:5]

cocMatrix(wos_final, Field = "CR", sep = ";")#Citation network
a<- cocMatrix(wos_final, Field = "CR", sep = ";")[2,]
View(a)
sum(a)
cocMatrix(wos_final, Field = "AU", sep = ";")#Author network

#Authors’ Countries is not a standard attribute of the bibliographic data frame. 
#You need to extract this information from affiliation attribute using the function metaTagExtraction.
metaTagExtraction(wos_final, Field = "AU_CO", sep = ";")#Country network


cocMatrix(wos_final, Field = "DE", sep = ";")#Author keyword network
cocMatrix(wos_final, Field = "ID", sep = ";")#Keyword Plus network


#psycinfo
psycinfo_network <- cocMatrix(psycinfo_final, Field = "SO", sep = ";")
sort(Matrix::colSums(psycinfo_network), decreasing = TRUE)[1:5]
# cocMatrix(psycinfo_final, Field = "CR", sep = ";")#Citation network
cocMatrix(psycinfo_final, Field = "AU", sep = ";")#Author network
# metaTagExtraction(psycinfo_final, Field = "AU_CO", sep = ";")#Country network
cocMatrix(psycinfo_final, Field = "DE", sep = ";")#Author keyword network
# cocMatrix(psycinfo_final, Field = "ID", sep = ";")#Keyword Plus network

#pubmed
pubmed_network <- cocMatrix(pubmed_final, Field = "SO", sep = ";")
sort(Matrix::colSums(pubmed_network), decreasing = TRUE)[1:5]
# cocMatrix(pubmed_final, Field = "CR", sep = ";")#Citation network
cocMatrix(pubmed_final, Field = "AU", sep = ";")#Author network
metaTagExtraction(pubmed_final, Field = "AU_CO", sep = ";")#Country network
cocMatrix(pubmed_final, Field = "DE", sep = ";")#Author keyword network
# cocMatrix(pubmed_final, Field = "ID", sep = ";")#Keyword Plus network

##################
####Bibliographic coupling
##################


NetMatrix_wos_ref_coupling <- biblioNetwork(wos_final, analysis = "coupling", network = "references", sep = "; ") #paper*references
NetMatrix_wos_au_coupling <- biblioNetwork(wos_final, analysis = "coupling", network = "authors", sep = "; ")#author*references
# NetMatrix_wos_au_coupling <- biblioNetwork(wos_final, analysis = "coupling", network = "sources", sep = "; ")#journal*references

# a<- biblioNetwork(wos_final, analysis = "coupling", network = "references", sep = "; ")[2,]
# View(a)

summary(networkStat(NetMatrix_wos_ref_coupling))
summary(networkStat(NetMatrix_wos_au_coupling))

net=networkPlot(NetMatrix_wos_ref_coupling, n = dim(NetMatrix_wos_ref_coupling)[1], Title = "references coupling", type = "circle", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")
net=networkPlot(NetMatrix_wos_ref_coupling, n = dim(NetMatrix_wos_ref_coupling)[1], Title = "references coupling", type = "sphere", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")
net=networkPlot(NetMatrix_wos_ref_coupling, n = dim(NetMatrix_wos_ref_coupling)[1], Title = "references coupling", type = "mds", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")
net=networkPlot(NetMatrix_wos_ref_coupling, n = dim(NetMatrix_wos_ref_coupling)[1], Title = "references coupling", type = "fruchterman", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")
net=networkPlot(NetMatrix_wos_ref_coupling, n = dim(NetMatrix_wos_ref_coupling)[1], Title = "references coupling", type = "kamada", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")


net=networkPlot(NetMatrix_wos_ref_coupling, n = 30, Title = "references coupling", type = "circle", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")
net=networkPlot(NetMatrix_wos_ref_coupling, n = 30, Title = "references coupling", type = "sphere", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")
net=networkPlot(NetMatrix_wos_ref_coupling, n = 30, Title = "references coupling", type = "mds", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")
net=networkPlot(NetMatrix_wos_ref_coupling, n = 30, Title = "references coupling", type = "fruchterman", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")
net=networkPlot(NetMatrix_wos_ref_coupling, n = 30, Title = "references coupling", type = "kamada", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")


net2VOSviewer(net)


net=networkPlot(NetMatrix_wos_au_coupling, n = 30, Title = "references coupling", type = "kamada", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")


##################
####Co-Citation Network
##################
NetMatrix <- biblioNetwork(wos_final, analysis = "co-citation", network = "references", sep = ";")
net=networkPlot(NetMatrix, n = 30, Title = "Co-Citation Network", type = "kamada", size=T, remove.multiple=FALSE, labelsize=0.7,edgesize = 5)

NetMatrix <- biblioNetwork(wos_final, analysis = "co-citation", network = "authors", sep = ";")
net=networkPlot(NetMatrix, n = 30, Title = "Co-Citation Network", type = "kamada", size=T, remove.multiple=FALSE, labelsize=0.7,edgesize = 5)


##################
####Collaboration
##################
#wos
NetMatrix <- biblioNetwork(wos_final, analysis = "collaboration", network = "authors", sep = ";")
net=networkPlot(NetMatrix,degree=15, Title = "Authors Collaboration", type = "kamada", size=TRUE, remove.multiple=F,weighted=T,labelsize=2,cluster="none")
# net2VOSviewer(net)

M <- metaTagExtraction(wos_final, Field = "AU_CO", sep = ";")
NetMatrix <- biblioNetwork(M, analysis = "collaboration", network = "countries", sep = ";")
net=networkPlot(NetMatrix, n=20, Title = "Country Collaboration", type = "kamada", size=TRUE, remove.multiple=FALSE,weighted=T,labelsize=2,
                cluster="none", edges.min=0, edgesize=15)



M <- metaTagExtraction(wos_final, Field = "AU_UN", sep = ";")
#_______clean M___________
for (i in 1: dim(M)[1]){
  tmp<- unlist(strsplit(M$AU_UN[i],";"))
  b<- grep("(CORRESPONDING AUTHOR)", tmp)
  if(length(b)>=1){
    tmp<- tmp[-b]
    M$AU_UN[i] <- paste(tmp,collapse = ";")
  }
  

}
         
#_________________________

NetMatrix <- biblioNetwork(M, analysis = "collaboration", network = "universities", sep = ";")
net=networkPlot(NetMatrix,  n =20, Title = "Institution Collaboration", type = "kamada", size=TRUE, remove.multiple=FALSE,weighted=T,labelsize=2,
                cluster="none",edges.min=0, edgesize=15)
# need to clean
# net2VOSviewer(net)




#pubmed
NetMatrix <- biblioNetwork(pubmed_final, analysis = "collaboration", network = "authors", sep = ";")
net=networkPlot(NetMatrix,degree=25, Title = "Authors Collaboration", type = "kamada", size=TRUE, remove.multiple=F,weighted=T,labelsize=2,cluster="none")

M <- metaTagExtraction(pubmed_final, Field = "AU_CO", sep = ";")
NetMatrix <- biblioNetwork(M, analysis = "collaboration", network = "countries", sep = ";")
net=networkPlot(NetMatrix,n=20, Title = "Country Collaboration", type = "kamada", size=TRUE, remove.multiple=FALSE,weighted=T,labelsize=2,
                cluster="none",edges.min=0, edgesize=15)

M <- metaTagExtraction(pubmed_final, Field = "AU_UN", sep = ";")
#_______clean M___________


for (i in 1: dim(M)[1]){
  tmp<- unlist(strsplit(M$AU_UN[i],";"))
  b<- grep("(CORRESPONDING AUTHOR)", tmp)
  if(length(b)>=1){
    tmp<- tmp[-b]
    M$AU_UN[i] <- paste(tmp,collapse = ";")
  }
  
  
}
#_________________________

NetMatrix <- biblioNetwork(M, analysis = "collaboration", network = "universities", sep = ";")
net=networkPlot(NetMatrix, n =20, Title = "Institution Collaboration", type = "kamada", size=TRUE, remove.multiple=FALSE,labelsize=2,
                cluster="none",edges.min=0, edgesize=15)


##################
####Co-word
##################


NetMatrix <- biblioNetwork(wos_final, analysis = "co-occurrences", network = "keywords", sep = ";")
net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 30, Title = "Keyword Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)
conceptualStructure(wos_final,field="DE", method="MCA", minDegree=3, clust=2, stemming=FALSE, labelsize=10, documents=10)
conceptualStructure(wos_final,field="ID", method="MCA", minDegree=3, clust=2, stemming=FALSE, labelsize=10, documents=10)

NetMatrix <- biblioNetwork(psycinfo_final, analysis = "co-occurrences", network = "keywords", sep = ";")
net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 30, Title = "Keyword Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)
conceptualStructure(psycinfo_final,field="DE", method="MCA", minDegree=15, clust=4, stemming=FALSE, labelsize=10, documents=10)

NetMatrix <- biblioNetwork(pubmed_final, analysis = "co-occurrences", network = "keywords", sep = ";")
net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 30, Title = "Keyword Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)
conceptualStructure(pubmed_final,field="DE", method="MCA", minDegree=6, clust=2, stemming=FALSE, labelsize=10, documents=10)





# NetMatrix <- biblioNetwork(wos_final, analysis = "co-occurrences", network = "authors", sep = ";")
# net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 30, Title = "Author Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)
# 
# NetMatrix <- biblioNetwork(psycinfo_final, analysis = "co-occurrences", network = "authors", sep = ";")
# net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 30, Title = "Author Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)
# 
# NetMatrix <- biblioNetwork(pubmed_final, analysis = "co-occurrences", network = "authors", sep = ";")
# net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 30, Title = "Author Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)


# NetMatrix <- biblioNetwork(wos_final, analysis = "co-occurrences", network = "sources", sep = ";")
# net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 50, Title = "Source Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)
# 
# NetMatrix <- biblioNetwork(psycinfo_final, analysis = "co-occurrences", network = "sources", sep = ";")
# net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 50, Title = "Source Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)
# 
# NetMatrix <- biblioNetwork(pubmed_final, analysis = "co-occurrences", network = "sources", sep = ";")
# net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 50, Title = "Source Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)

# threeFieldsPlot (rayyan_30,fields = c("AU", "DE", "SO"), n = c(20, 20, 20))
#_______clean Rayyan_________

i=3
# for (i in 1: dim(rayyan_30)[1]){
#   tmp<- unlist(strsplit(rayyan_30$DE[i],";"))
#   b<- grep("\\*", tmp)
#   if (sum(b)>=1){
#     rayyan_30$DE[i]<- NA
#   }
# }
# 
# sum(is.na(rayyan_30$DE))
#_________________________


#_______input with pubmed$OT_________
rayyan_30 <- rayyan[rayyan$PY!=2021&rayyan$PY!=1990,]
matching <- rayyan_30$TI


for (i in 1:length(matching)) {

  testing <- sum(na.omit(matching[i]==pubmed_final$TI))

  if (testing==1)
  {
    rayyan_30[i,]$DE <- pubmed_final[matching[i]==pubmed_final$TI,]$OT
  }
}

rayyan_30$DE<- str_replace_all(rayyan_30$DE,"\\*", "")

i=53
for (i in 1: dim(rayyan_30)[1]){
  tmp<- unlist(strsplit(rayyan_30$DE[i],";"))
  b<- grep("HUMANS", tmp)
  if(length(b)>=1){
    tmp<- tmp[-b]
    rayyan_30$DE[i] <- paste(tmp,collapse = ";")
  }
}

#_________________________




M<- thematicEvolution(rayyan_30,field = "DE",years = c(2000,2010));M
plotThematicEvolution(M$Nodes,M$Edges)
# 9 other indices ---------------------------------------------------------

#dominance
dominance(results_wos, k = 10)
dominance(results_psycinfo, k = 10)
dominance(results_pubmed, k = 10)

#Top-Authors’ Productivity over the Time
authorProdOverTime(wos_final, k = 10, graph = TRUE)
authorProdOverTime(psycinfo_final, k = 10, graph = TRUE)
authorProdOverTime(pubmed_final, k = 10, graph = TRUE)

#Lotka’s Law coefficient estimation
lotka(results_wos)
L<- lotka(results_wos)
# Observed distribution
Observed=L$AuthorProd[,3]
# Theoretical distribution with Beta = 2
Theoretical=10^(log10(L$C)-2*log10(L$AuthorProd[,1]))
plot(L$AuthorProd[,1],Theoretical,type="l",col="red",ylim=c(0, 1), xlab="Articles",ylab="Freq. of Authors",main="Scientific Productivity")
lines(L$AuthorProd[,1],Observed,col="blue")
legend(x="topright",c("Theoretical (B=2)","Observed"),col=c("red","blue"),lty = c(1,1,1),cex=0.6,bty="n")

#Historical Direct Citation Network
histResults <- histNetwork(wos_final, min.citations = 1, sep = ";")
net <- histPlot(histResults, n=15, size = 10, labelsize=5)
