## ----eval=FALSE----------------------------------------------------------
#  devtools::install_github("garthtarr/pairsD3")

## ----load----------------------------------------------------------------
require(edgebundleR)

## ----, results='asis'----------------------------------------------------
require(igraph)
ws_graph <- watts.strogatz.game(1, 50, 4, 0.05)
edgebundle(ws_graph,tension = 0.1,fontsize = 20,width=600,height=600)

## ----, message=FALSE,warning=FALSE---------------------------------------
require(mvtnorm)
sig = kronecker(diag(3),matrix(2,5,5)) +3*diag(15)
X = mvrnorm(n=100,mu=rep(0,15),Sigma = sig)
colnames(X) = paste(rep(c("A.A","B.B","C.C"),each=5),1:5,sep="")
edgebundle(cor(X),cutoff=0.2,tension=0.8,fontsize = 14)

## ----, message=FALSE,warning=FALSE---------------------------------------
require(huge)
data("stockdata")
# generate returns sequences
X = log(stockdata$data[2:1258,]/stockdata$data[1:1257,])
# format the colnames
colnames(X) = paste(gsub("","",stockdata$info[,2]),stockdata$info[,1],sep=".")
head(cbind(stockdata$info[,2],stockdata$info[,1],colnames(X)))
# perform some regularisation
out.huge = huge(cor(X),method = "glasso",lambda=0.56,verbose = FALSE)
# identify the linkages
adj.mat = as.matrix(out.huge$path[[1]])
colnames(adj.mat) = rownames(adj.mat) = colnames(corX)
# restrict attention to the connected stocks:
adj.mat = adj.mat[rowSums(adj.mat)>0,colSums(adj.mat)>0]
# plot the result
edgebundle(adj.mat,tension=0.8,fontsize = 10)

## ----jsoninput1----------------------------------------------------------
filepath = system.file("sampleData", "flare-imports.json", package = "edgebundleR")
filepath

## ----jsoninput2, results='asis'------------------------------------------
edgebundle(filepath,width=800,height=800,fontsize=8,tension=0.95)

## ----, eval=FALSE--------------------------------------------------------
#  system(paste("head -4",filepath))

## ------------------------------------------------------------------------
ws_graph <- watts.strogatz.game(1, 50, 4, 0.05)
edgebundle(ws_graph,tension = 0.1,fontsize = 20)

## ------------------------------------------------------------------------
g = edgebundle(ws_graph,tension = 0.1,fontsize = 20,width=600,height=600)
saveEdgebundle(g,file = "ws_graph.html")

